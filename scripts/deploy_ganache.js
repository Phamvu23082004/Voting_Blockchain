const hre = require("hardhat");

async function main() {
  const [admin] = await hre.ethers.getSigners();
  console.log("Deploying contract with:", admin.address);

  const Election = await hre.ethers.getContractFactory("E_Voting");
  const election = await Election.deploy();
  await election.waitForDeployment();
  console.log("✅ Contract deployed at:", await election.getAddress());

  const OnchainHashVerifier = await hre.ethers.getContractFactory("OnchainHashVerifier");
  const hashVerifier = await OnchainHashVerifier.deploy();
  await hashVerifier.waitForDeployment();
  console.log("✅ OnchainHashVerifier deployed at:", await hashVerifier.getAddress());

  const TallyVerifierOnChain = await hre.ethers.getContractFactory("TallyVerifierOnChain");
  const tallyVerifier = await TallyVerifierOnChain.deploy();
  await tallyVerifier.waitForDeployment();
  console.log("✅ TallyVerifierOnChain deployed at:", await tallyVerifier.getAddress());
}  
main().catch((error) => {
  console.error(error);
  process.exit(1);
});
