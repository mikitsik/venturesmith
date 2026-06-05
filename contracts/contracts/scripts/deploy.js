const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying with:", deployer.address);

  const VentureSmithRegistry = await hre.ethers.getContractFactory(
    "VentureSmithRegistry"
  );

  const registry = await VentureSmithRegistry.deploy(deployer.address);
  await registry.waitForDeployment();

  const address = await registry.getAddress();

  console.log("VentureSmithRegistry deployed to:", address);
  console.log("Agent executor:", deployer.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
