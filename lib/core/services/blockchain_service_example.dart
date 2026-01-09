/// Demo/Example: How to use BlockchainService
///
/// This file shows how to integrate blockchain NFT minting into your app.
/// Copy these patterns into your actual services (like StreakService)

import 'package:smart_fitness_assistant/core/services/blockchain_service.dart';

/// Example 1: Mint NFT when user achieves 7-day streak
Future<void> exampleMintStreakBadge() async {
  final blockchainService = BlockchainService();

  try {
    // User's wallet address (from their profile or MetaMask)
    const userWalletAddress = '0xbf415e204220c66732243c1B5DBfB45310dcC3bc';

    // Owner's private key (YOUR private key - keep secret!)
    // In production: Store in secure backend, never in app
    const ownerPrivateKey = 'YOUR_PRIVATE_KEY_HERE'; // ⚠️ NEVER commit this!

    // Mint 7-day streak badge
    final tokenId = await blockchainService.mintStreakBadge(
      userAddress: userWalletAddress,
      streakDays: 7,
      privateKey: ownerPrivateKey,
    );

    print('✅ Minted NFT token ID: $tokenId');
    print(
      '🔗 View on explorer: https://amoy.polygonscan.com/token/0x365d5d61596E2d1FaA9111c20C428009c69748cd?a=$tokenId',
    );
  } catch (e) {
    print('❌ Error minting badge: $e');
  }
}

/// Example 2: Get user's NFT collection
Future<void> exampleGetUserBadges() async {
  final blockchainService = BlockchainService();

  try {
    const userWalletAddress = '0xbf415e204220c66732243c1B5DBfB45310dcC3bc';

    // Get all token IDs owned by user
    final tokenIds = await blockchainService.getUserBadges(userWalletAddress);

    print('User has ${tokenIds.length} NFT badges: $tokenIds');

    // Get details of each badge
    for (final tokenId in tokenIds) {
      final metadata = await blockchainService.getBadgeMetadata(tokenId);
      print('Token #$tokenId: ${metadata?['achievementValue']} days streak');
    }
  } catch (e) {
    print('❌ Error getting badges: $e');
  }
}

/// Example 3: Integration with StreakService
/// 
/// Add this to your StreakService.recordWorkout() method:
/// 
/// ```dart
/// Future<StreakResult> recordWorkout(String userId) async {
///   // ... existing code ...
///   
///   // Check if milestone reached
///   if (_isStreakMilestone(newStreak)) {
///     // ✅ MINT NFT ON BLOCKCHAIN
///     try {
///       final userProfile = await getUserProfile(userId); // Get user's wallet
///       
///       if (userProfile.walletAddress != null) {
///         final tokenId = await BlockchainService().mintStreakBadge(
///           userAddress: userProfile.walletAddress!,
///           streakDays: newStreak,
///           privateKey: const String.fromEnvironment('OWNER_PRIVATE_KEY'),
///         );
///         
///         print('🎉 NFT minted! Token ID: $tokenId');
///       }
///     } catch (e) {
///       print('⚠️ Failed to mint NFT (will retry): $e');
///       // Don't fail the whole operation if blockchain fails
///     }
///   }
///   
///   // ... rest of existing code ...
/// }
/// ```

/// Example 4: Display NFT in UI
/// 
/// ```dart
/// class NFTBadgesScreen extends StatelessWidget {
///   final String userWalletAddress;
///   
///   @override
///   Widget build(BuildContext context) {
///     return FutureBuilder<List<int>>(
///       future: BlockchainService().getUserBadges(userWalletAddress),
///       builder: (context, snapshot) {
///         if (snapshot.hasData) {
///           final tokenIds = snapshot.data!;
///           return GridView.builder(
///             itemCount: tokenIds.length,
///             itemBuilder: (context, index) {
///               return NFTBadgeCard(tokenId: tokenIds[index]);
///             },
///           );
///         }
///         return CircularProgressIndicator();
///       },
///     );
///   }
/// }
/// ```

/// ⚠️ IMPORTANT SECURITY NOTES:
/// 
/// 1. NEVER store private key in app code
/// 2. Use backend server to mint NFTs (call from Flutter → Your server → Blockchain)
/// 3. Or use WalletConnect to let users sign transactions with their own wallet
/// 4. Current implementation is for TESTNET ONLY (safe to use test private key)
/// 5. For PRODUCTION, implement proper backend API for minting
