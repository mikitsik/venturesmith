const hre = require("hardhat");

const REGISTRY_ADDRESS = process.env.SOMNIA_REGISTRY_ADDRESS;

async function main() {
  if (!REGISTRY_ADDRESS) {
    throw new Error("SOMNIA_REGISTRY_ADDRESS is missing");
  }

  const metadataHash = process.env.PASSPORT_METADATA_HASH;
  const metadataURI = process.env.PASSPORT_METADATA_URI;

  if (!metadataHash || !metadataURI) {
    throw new Error("PASSPORT_METADATA_HASH and PASSPORT_METADATA_URI are required");
  }

  const registry = await hre.ethers.getContractAt(
    "VentureSmithRegistry",
    REGISTRY_ADDRESS
  );

  const tx = await registry.createOpportunityPassport(
    metadataHash,
    metadataURI
  );

  const receipt = await tx.wait();

  const event = receipt.logs
    .map((log) => {
      try {
        return registry.interface.parseLog(log);
      } catch (_error) {
        return null;
      }
    })
    .find((parsed) => parsed && parsed.name === "OpportunityPassportCreated");

  if (!event) {
    throw new Error("OpportunityPassportCreated event not found");
  }

  console.log(JSON.stringify({
    tx_hash: tx.hash,
    passport_id: event.args.passportId.toString(),
    metadata_hash: metadataHash,
    metadata_uri: metadataURI
  }));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
