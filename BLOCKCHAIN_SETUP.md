# 🔗 Blockchain Integration Guide

## 📋 Current Status

Your app now supports **HYBRID MODE** for NFT badges:

- ✅ **Mock Mode (Default)**: Fast, free, uses Supabase database
- 🔗 **Blockchain Mode**: Real NFTs on Polygon blockchain

---

## 🚀 How to Enable Real Blockchain

### Step 1: Get Your Configuration

You need 2 things:

#### 1. **Owner Private Key** (to mint NFTs)

- Your MetaMask private key that deployed the contract
- Export from MetaMask: Settings → Security & Privacy → Show Private Key
- ⚠️ Keep this SECRET! Never commit to git

#### 2. **User Wallet Address** (to receive NFTs)

- The wallet address where badges will be sent
- Can be same as owner or different user wallet
- Format: `0x1234567890abcdef...`

### Step 2: Update Configuration

Open file: `lib/views/achievements/logic/cubit/achievement_cubit.dart`

Find these lines (~line 30):

```dart
// 🔧 CONFIG: Toggle blockchain mode
static const bool useBlockchain = false;  // ← Change to true

// 🔐 BLOCKCHAIN CONFIG
static const String ownerPrivateKey = 'YOUR_PRIVATE_KEY_HERE';      // ← Paste private key
static const String userWalletAddress = '0xYOUR_WALLET_ADDRESS';   // ← Paste wallet address
```

Update to:

```dart
static const bool useBlockchain = true;  // ✅ ENABLED

static const String ownerPrivateKey = '79058a6b72e672efad15bd16d6706a3d0c81b08d313b479f62f2566dd1283f6d';
static const String userWalletAddress = '0xbf415e204220c66732243c1B5DBfB45310dcC3bc';
```

### Step 3: Ensure You Have Test MATIC

Check your wallet has testnet MATIC:

- Network: Polygon Amoy Testnet
- Balance: At least 0.1 MATIC (enough for ~100 transactions)
- Faucet: https://faucet.polygon.technology/

### Step 4: Rebuild & Test

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🎯 How It Works

### Hybrid Mode Benefits:

When `useBlockchain = true`:

1. **Always saves to database** (fast, reliable backup)
2. **Also mints real NFT** on Polygon blockchain (2-5 seconds)
3. **If blockchain fails**: Badge still saved in database (no data loss)

### Workflow:

```
User completes workout
    ↓
mintWorkoutBadge() called
    ↓
✅ Save to Supabase (instant)
    ↓
🔗 Mint NFT on Polygon (if enabled)
    ↓
✅ Badge appears in app
    ↓
🔍 Verify on PolygonScan
```

---

## 🧪 Testing

### Test Real Blockchain Minting:

1. Enable blockchain mode (see Step 2)
2. Open app → Workout Plan
3. Complete a workout with 10-15 exercises
4. Finish workout
5. Watch console logs:

```
🔗 Minting NFT on Polygon blockchain...
📋 Transaction sent: 0xabc123...
✅ NFT minted on-chain! Token ID: 1
🔍 View on PolygonScan: https://amoy.polygonscan.com/token/...
```

6. Click the PolygonScan link to verify!

### Verify NFT on PolygonScan:

```
https://amoy.polygonscan.com/token/0x365d5d61596E2d1FaA9111c20C428009c69748cd
```

Check:

- ✅ Token Transfers tab → Your NFT
- ✅ Read Contract → `getUserBadges(address)` → See your token IDs
- ✅ Token ID details → See metadata

---

## 🔒 Security Best Practices

### ⚠️ NEVER in Production:

- ❌ DON'T hardcode private key in app
- ❌ DON'T commit private key to git
- ❌ DON'T expose private key in APK

### ✅ Production Approach:

**Use Backend Server:**

```
Flutter App → Your Backend API → Blockchain
```

1. User completes workout
2. App sends request to YOUR server
3. Server validates & mints NFT (server holds private key)
4. Server returns token ID to app

**Benefits:**

- Private key stays secure on server
- Rate limiting & abuse prevention
- Gas fee optimization
- Better UX (no wallet needed for user)

### For Testnet Demo Only:

Current implementation is OK for testnet because:

- Uses test MATIC (no real value)
- Contract deployed on testnet
- Educational purpose

---

## 📊 Cost Estimate

### Testnet (Current):

- ✅ **FREE** - Test MATIC from faucet
- ✅ Unlimited minting

### Mainnet (Production):

- Gas per mint: ~$0.001 - $0.005 USD
- 1000 badges: ~$1 - $5 USD
- Very affordable compared to Ethereum!

---

## 🆘 Troubleshooting

### "insufficient funds for gas"

- Get more test MATIC from faucet
- Wait 2-3 minutes for faucet to process

### "Transaction timeout"

- Network congestion (rare on Polygon)
- Try again or increase timeout

### "Blockchain mint failed (badge still saved)"

- Badge saved to database (user still gets it)
- Check console for specific error
- Verify wallet has MATIC

### Private key error

- Remove "0x" prefix if present
- Should be exactly 64 hex characters
- Check no spaces or hidden characters

---

## 🎓 Understanding the Code

### Toggle Flag:

```dart
static const bool useBlockchain = false;
```

- `false` (default): Mock mode - database only
- `true`: Hybrid mode - database + blockchain

### Mint Logic:

```dart
// 1. ALWAYS save to database
final badge = await _mockService.mintBadge(...);

// 2. OPTIONAL: Mint on blockchain
if (useBlockchain) {
  final tokenId = await _blockchainService.mintWorkoutBadge(...);
}
```

**Why hybrid?**

- User experience: Badge shows immediately (from database)
- Blockchain: Permanent, verifiable proof
- Fallback: If blockchain fails, badge still exists

---

## 🚀 Next Steps

After testing on testnet:

1. ✅ Deploy contract to Polygon Mainnet
2. ✅ Implement backend API for minting
3. ✅ Add WalletConnect for user wallets
4. ✅ Display PolygonScan links in app
5. ✅ Show gas fees to users
6. ✅ Add "Verify on Blockchain" button

---

## 📚 Resources

- Contract Address: `0x365d5d61596E2d1FaA9111c20C428009c69748cd`
- Network: Polygon Amoy Testnet (ChainID: 80002)
- RPC: `https://rpc-amoy.polygon.technology`
- Explorer: https://amoy.polygonscan.com
- Faucet: https://faucet.polygon.technology

---

**Ready to mint real NFTs? Just change one flag! 🎉**
