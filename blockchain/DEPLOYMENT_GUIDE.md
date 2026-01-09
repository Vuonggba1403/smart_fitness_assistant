# 🚀 Smart Contract Deployment Guide

Hướng dẫn deploy NFT smart contract cho Smart Fitness Assistant lên blockchain.

## 📋 Prerequisites

### 1. Cài đặt Node.js

```bash
# Download từ: https://nodejs.org/
# Hoặc dùng nvm:
nvm install 20
nvm use 20
```

### 2. Tạo Wallet (MetaMask)

1. Install MetaMask extension: https://metamask.io/
2. Tạo wallet mới hoặc import existing
3. **LƯU GIỮ CẨN THẬN**: Secret Recovery Phrase (12 từ)

### 3. Lấy Test Tokens (FREE)

#### Option A: Polygon Amoy Testnet (RECOMMENDED - Free & Fast)

1. Add Polygon Amoy network to MetaMask:

   - Network Name: `Polygon Amoy Testnet`
   - RPC URL: `https://rpc-amoy.polygon.technology`
   - Chain ID: `80002`
   - Currency Symbol: `MATIC`
   - Block Explorer: `https://amoy.polygonscan.com/`

2. Get free MATIC tokens:
   - Faucet 1: https://faucet.polygon.technology/
   - Faucet 2: https://www.alchemy.com/faucets/polygon-amoy

#### Option B: Sepolia Testnet (Ethereum)

1. Add Sepolia network to MetaMask
2. Get free ETH: https://sepoliafaucet.com/

#### Option C: BSC Testnet

1. Add BSC Testnet network
2. Get free BNB: https://testnet.bnbchain.org/faucet-smart

---

## 🛠️ Setup & Installation

### Step 1: Di chuyển vào thư mục blockchain

```bash
cd d:\Dev\Source\flutter_code\smart_fitness_assistant\blockchain
```

### Step 2: Cài đặt dependencies

```bash
npm install
```

### Step 3: Tạo file .env

```bash
# Copy file mẫu
copy .env.example .env

# Chỉnh sửa .env và điền:
# 1. PRIVATE_KEY của wallet (từ MetaMask)
# 2. Các RPC URLs (có thể dùng mặc định)
```

⚠️ **QUAN TRỌNG**:

- KHÔNG SHARE file `.env` với ai
- KHÔNG commit `.env` lên Git
- Chỉ dùng testnet wallet, KHÔNG dùng wallet chính

### Step 4: Compile Smart Contract

```bash
npm run compile
```

Kết quả mong đợi:

```
✓ Compiled 1 Solidity file successfully
```

---

## 🚢 Deploy Smart Contract

### Deploy lên Polygon Amoy Testnet (RECOMMENDED)

```bash
npm run deploy:amoy
```

### Hoặc deploy lên mạng khác:

```bash
# Polygon Mumbai (đang deprecated)
npm run deploy:mumbai

# BSC Testnet
npm run deploy:bsc-test

# Sepolia (Ethereum testnet)
npm run deploy:sepolia

# Polygon Mainnet (PRODUCTION - tốn tiền thật)
npm run deploy:polygon
```

---

## ✅ Kết quả Deploy

Sau khi deploy thành công, bạn sẽ thấy:

```
✅ FitnessNFT deployed to: 0xYourContractAddress123...
📋 Transaction hash: 0xTransactionHash456...

🔗 Add this to your Flutter app:
CONTRACT_ADDRESS=0xYourContractAddress123...
NETWORK=polygonAmoy
```

**LƯU LẠI**:

- ✅ `CONTRACT_ADDRESS` - Địa chỉ contract vừa deploy
- ✅ `NETWORK` - Tên mạng đã deploy
- ✅ File `deployment-info.json` được tạo tự động

---

## 🔍 Verify Contract (Optional)

Để verify contract trên block explorer:

```bash
npx hardhat verify --network polygonAmoy YOUR_CONTRACT_ADDRESS
```

Lợi ích:

- ✅ Source code public trên explorer
- ✅ Users có thể đọc/write trực tiếp
- ✅ Tăng trust & transparency

---

## 🧪 Test Contract

### Test locally:

```bash
npm test
```

### Test trên testnet (thủ công):

1. Vào block explorer:

   - Polygon Amoy: https://amoy.polygonscan.com/
   - Paste contract address

2. Tab "Contract" > "Write Contract"
3. Connect MetaMask
4. Test function `mintStreakBadge`:
   - `to`: Your wallet address
   - `streakDays`: 7
   - `metadataURI`: `ipfs://test-metadata`
   - Click "Write" → Confirm transaction

---

## 📱 Tích hợp vào Flutter App

Sau khi deploy thành công, làm theo các bước sau:

### Step 1: Thêm dependencies vào pubspec.yaml

```yaml
dependencies:
  web3dart: ^2.7.3
  http: ^1.2.0 # đã có
```

### Step 2: Tạo file config

Tạo file `lib/core/config/blockchain_config.dart`:

```dart
class BlockchainConfig {
  static const String contractAddress = 'YOUR_CONTRACT_ADDRESS';
  static const String rpcUrl = 'https://rpc-amoy.polygon.technology';
  static const int chainId = 80002;
}
```

### Step 3: Implement BlockchainService

Tham khảo file hướng dẫn trong thư mục `lib/core/services/`

---

## 🔐 Security Checklist

- [ ] ✅ Private key KHÔNG được commit lên Git
- [ ] ✅ File `.env` trong `.gitignore`
- [ ] ✅ Chỉ deploy testnet lúc đầu
- [ ] ✅ Test kỹ trước khi deploy mainnet
- [ ] ✅ Backup wallet recovery phrase
- [ ] ✅ Dùng separate wallet cho development

---

## 🆘 Troubleshooting

### Error: "insufficient funds"

- ➡️ Lấy thêm test tokens từ faucet
- ➡️ Đợi vài phút sau khi claim từ faucet

### Error: "invalid private key"

- ➡️ Check format private key (64 ký tự hex, không có "0x")
- ➡️ Export lại từ MetaMask

### Error: "nonce too low"

- ➡️ Reset MetaMask account: Settings > Advanced > Reset Account

### Transaction pending quá lâu

- ➡️ Tăng gas price trong hardhat.config.js
- ➡️ Thử lại sau 5-10 phút

---

## 📚 Resources

- **Hardhat Docs**: https://hardhat.org/docs
- **OpenZeppelin Contracts**: https://docs.openzeppelin.com/contracts
- **Polygon Docs**: https://docs.polygon.technology/
- **Web3dart Flutter**: https://pub.dev/packages/web3dart
- **MetaMask Guide**: https://metamask.io/faqs/

---

## 💰 Cost Estimate

### Testnet: **HOÀN TOÀN MIỄN PHÍ** ✅

- Free test tokens từ faucet
- Deploy unlimited times
- Test đầy đủ tính năng

### Mainnet (Polygon):

- Deploy contract: ~$0.10-0.50
- Mint NFT: ~$0.01-0.05 mỗi badge
- Total: < $1 cho toàn bộ setup

### Mainnet (Ethereum):

- Deploy: $50-200 (đắt hơn nhiều)
- Mint NFT: $10-50 mỗi badge
- ❌ KHÔNG RECOMMEND cho fitness app

---

## 🎯 Next Steps

Sau khi deploy thành công:

1. ✅ Test mint NFT trên testnet
2. ✅ Tích hợp vào Flutter app (tôi sẽ hướng dẫn tiếp)
3. ✅ Setup IPFS cho metadata
4. ✅ Test end-to-end workflow
5. ✅ Deploy mainnet khi ready

---

**Need help?** Hỏi tôi bất cứ lúc nào! 🚀
