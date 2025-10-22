const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  console.log("🚀 Đang deploy HashCommitCheckVerifier...");

  // 🧩 Compile contract nếu chưa có build
  await hre.run("compile");

  // 🧾 Lấy account từ private key
  const [deployer] = await ethers.getSigners();
  console.log("👤 Triển khai bằng địa chỉ:", deployer.address);

  // 🧱 Triển khai contract
  const Verifier = await ethers.getContractFactory("OnchainVerifier");
  const verifier = await Verifier.deploy();

  await verifier.waitForDeployment();

  const address = await verifier.getAddress();
  console.log("✅ Deploy thành công!");
  console.log("📜 Địa chỉ contract:", address);

//   // 💾 Lưu lại địa chỉ vào file JSON để BE hoặc frontend dùng
//   const fs = require("fs");
//   fs.writeFileSync(
//     "./deployments/hashCommitVerifier.json",
//     JSON.stringify({ address }, null, 2)
//   );

//   console.log("💾 Đã lưu địa chỉ tại deployments/hashCommitVerifier.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Lỗi deploy:", error);
    process.exit(1);
  });
