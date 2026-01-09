const hre = require("hardhat");

async function main() {
  console.log("🚀 Starting FitnessNFT deployment...\n");

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Deploying contracts with account:", deployer.address);
  
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", hre.ethers.formatEther(balance), "ETH/MATIC\n");

  // Deploy contract
  console.log("⏳ Deploying FitnessNFT contract...");
  const FitnessNFT = await hre.ethers.getContractFactory("FitnessNFT");
  const fitnessNFT = await FitnessNFT.deploy();

  await fitnessNFT.waitForDeployment();
  const contractAddress = await fitnessNFT.getAddress();

  console.log("✅ FitnessNFT deployed to:", contractAddress);
  console.log("📋 Transaction hash:", fitnessNFT.deploymentTransaction().hash);
  
  // Wait for confirmations
  console.log("\n⏳ Waiting for block confirmations...");
  await fitnessNFT.deploymentTransaction().wait(5);
  console.log("✅ Contract confirmed!");

  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    contractAddress: contractAddress,
    deployer: deployer.address,
    deploymentTime: new Date().toISOString(),
    transactionHash: fitnessNFT.deploymentTransaction().hash,
  };

  console.log("\n" + "=".repeat(60));
  console.log("📄 DEPLOYMENT SUMMARY");
  console.log("=".repeat(60));
  console.log(JSON.stringify(deploymentInfo, null, 2));
  console.log("=".repeat(60));

  console.log("\n🔗 Add this to your Flutter app:");
  console.log(`CONTRACT_ADDRESS=${contractAddress}`);
  console.log(`NETWORK=${hre.network.name}`);

  // Save to file
  const fs = require("fs");
  fs.writeFileSync(
    "deployment-info.json",
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("\n💾 Deployment info saved to: deployment-info.json");

  console.log("\n✨ Deployment complete!");
  
  // Verify instructions
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("\n📝 To verify contract on block explorer, run:");
    console.log(`npx hardhat verify --network ${hre.network.name} ${contractAddress}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
