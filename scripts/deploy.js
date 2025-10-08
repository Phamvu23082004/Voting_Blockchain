const hre = require("hardhat");

async function main() {
  const [admin] = await hre.ethers.getSigners();
  console.log("Deploying contract with:", admin.address);

  const Election = await hre.ethers.getContractFactory("Election");
  const election = await Election.deploy();

  // ❌ Sai: await election.deployed();
  // ✅ Đúng:
  await election.waitForDeployment();

  console.log("✅ Contract deployed at:", await election.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
