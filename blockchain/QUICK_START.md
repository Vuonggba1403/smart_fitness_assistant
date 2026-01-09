# 🚀 HƯỚNG DẪN DEPLOY SMART CONTRACT - NHANH GỌN

## ⚡ Quick Start (5 phút)

### Bước 1: Setup Node.js

```bash
# Cài Node.js từ: https://nodejs.org/ (version 18 hoặc 20)
node --version  # Check đã cài chưa
```

### Bước 2: Cài MetaMask & Lấy Test Token

1. **Install MetaMask**: https://metamask.io/
2. **Add Polygon Amoy Testnet** vào MetaMask:
   - Open MetaMask → Networks → Add Network
   - Chọn "Polygon Amoy" hoặc thêm manual:
     ```
     Network Name: Polygon Amoy Testnet
     RPC URL: https://rpc-amoy.polygon.technology
     Chain ID: 80002
     Currency: MATIC
     ```
3. **Lấy FREE test MATIC**:
   - Vào: https://faucet.polygon.technology/
   - Paste địa chỉ wallet → Claim
   - Đợi 1-2 phút nhận token

### Bước 3: Export Private Key

1. MetaMask → Click 3 dots → Account Details
2. Click "Show Private Key"
3. Nhập password → Copy private key
   ⚠️ **KHÔNG SHARE với ai!**

---

## 🔧 Deploy Contract

### Bước 4: Setup Project

```bash
# Vào thư mục blockchain
cd d:\Dev\Source\flutter_code\smart_fitness_assistant\blockchain

# Cài packages
npm install

# Tạo file .env
copy .env.example .env
```

### Bước 5: Config Private Key

Mở file `.env` và điền:

```env
PRIVATE_KEY=paste_private_key_ở_đây_không_có_dấu_0x
```

### Bước 6: Deploy! 🚀

```bash
# Compile contract
npm run compile

# Deploy lên Polygon Amoy Testnet
npm run deploy:amoy
```

**Kết quả sẽ như:**

```
✅ FitnessNFT deployed to: 0x1234567890abcdef...
```

**COPY địa chỉ này!** Bạn sẽ cần nó cho Flutter app.

---

## 📱 Tích hợp vào Flutter

Sau khi có contract address, làm 3 việc:

### 1. Thêm dependencies

Mở `pubspec.yaml`, thêm vào `dependencies`:

```yaml
web3dart: ^2.7.3
```

Sau đó:

```bash
flutter pub get
```

### 2. Tạo config file

Tạo file `lib/core/config/blockchain_config.dart`:

```dart
class BlockchainConfig {
  // Thay YOUR_CONTRACT_ADDRESS bằng địa chỉ vừa deploy
  static const String contractAddress = 'YOUR_CONTRACT_ADDRESS';

  static const String rpcUrl = 'https://rpc-amoy.polygon.technology';
  static const int chainId = 80002;
  static const String networkName = 'Polygon Amoy Testnet';

  // ABI của contract (đã generate sẵn sau khi compile)
  static const String contractABI = '''[
    {
      "inputs": [
        {"name": "to", "type": "address"},
        {"name": "streakDays", "type": "uint256"},
        {"name": "metadataURI", "type": "string"}
      ],
      "name": "mintStreakBadge",
      "outputs": [{"type": "uint256"}],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [{"name": "user", "type": "address"}],
      "name": "getUserBadges",
      "outputs": [{"type": "uint256[]"}],
      "stateMutability": "view",
      "type": "function"
    }
  ]''';
}
```

### 3. Test thử

Vào block explorer kiểm tra:

- URL: `https://amoy.polygonscan.com/address/YOUR_CONTRACT_ADDRESS`
- Bạn sẽ thấy contract vừa deploy

---

## ✅ Checklist

- [ ] Node.js đã cài (v18+)
- [ ] MetaMask đã setup
- [ ] Polygon Amoy network đã thêm
- [ ] Có ít nhất 0.1 test MATIC trong wallet
- [ ] Private key đã export
- [ ] File `.env` đã tạo và điền private key
- [ ] `npm install` thành công
- [ ] `npm run compile` thành công
- [ ] `npm run deploy:amoy` thành công
- [ ] Copy được contract address
- [ ] Add `web3dart` vào pubspec.yaml
- [ ] Tạo `blockchain_config.dart`

---

## 🆘 Gặp lỗi?

### "insufficient funds for gas"

→ Lấy thêm test MATIC từ faucet, đợi 2-3 phút

### "invalid private key"

→ Check private key không có "0x" ở đầu, chỉ có 64 ký tự hex

### "command not found: npm"

→ Chưa cài Node.js, download tại nodejs.org

### Contract deploy rồi nhưng không thấy trên explorer

→ Đợi 1-2 phút, refresh lại trang

---

## 🎯 Bước tiếp theo

Sau khi deploy xong, tôi sẽ giúp bạn:

1. ✅ Tạo BlockchainService để gọi contract từ Flutter
2. ✅ Mint NFT khi user đạt streak milestone
3. ✅ Hiển thị NFT collection trong app
4. ✅ Setup IPFS cho metadata

**Hỏi tôi khi cần!** 🚀
