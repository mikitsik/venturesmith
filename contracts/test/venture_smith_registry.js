const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VentureSmithRegistry", function () {
  async function deployRegistryFixture() {
    const [owner, founder, platform] = await ethers.getSigners();

    const llmAgentId = 12847293847561029384n;

    const Registry = await ethers.getContractFactory(
      "VentureSmithRegistry"
    );

    const registry = await Registry.deploy(
      platform.address,
      llmAgentId
    );

    await registry.waitForDeployment();

    return {
      owner,
      founder,
      platform,
      llmAgentId,
      registry
    };
  }

  it("stores constructor values", async function () {
    const { owner, platform, llmAgentId, registry } =
      await deployRegistryFixture();

    expect(await registry.owner()).to.equal(owner.address);
    expect(await registry.platform()).to.equal(platform.address);
    expect(await registry.llmAgentId()).to.equal(llmAgentId);
  });

  it("creates opportunity passport", async function () {
    const { founder, registry } = await deployRegistryFixture();

    const metadataHash = ethers.keccak256(
      ethers.toUtf8Bytes("opportunity passport metadata")
    );

    const metadataURI = "rails://opportunities/1";

    await expect(
      registry
        .connect(founder)
        .createOpportunityPassport(metadataHash, metadataURI)
    )
      .to.emit(registry, "OpportunityPassportCreated")
      .withArgs(1n, founder.address, metadataHash, metadataURI);

    const passport = await registry.getOpportunityPassport(1n);

    expect(passport.founder).to.equal(founder.address);
    expect(passport.metadataHash).to.equal(metadataHash);
    expect(passport.score).to.equal(0n);
    expect(passport.resultHash).to.equal(ethers.ZeroHash);
  });

  it("increments passport ids", async function () {
    const { founder, registry } = await deployRegistryFixture();

    const firstHash = ethers.keccak256(ethers.toUtf8Bytes("first"));
    const secondHash = ethers.keccak256(ethers.toUtf8Bytes("second"));

    await registry
      .connect(founder)
      .createOpportunityPassport(firstHash, "rails://opportunities/1");

    await registry
      .connect(founder)
      .createOpportunityPassport(secondHash, "rails://opportunities/2");

    const firstPassport = await registry.getOpportunityPassport(1n);
    const secondPassport = await registry.getOpportunityPassport(2n);

    expect(firstPassport.metadataHash).to.equal(firstHash);
    expect(secondPassport.metadataHash).to.equal(secondHash);
    expect(await registry.nextPassportId()).to.equal(3n);
  });

  it("rejects empty metadata hash", async function () {
    const { founder, registry } = await deployRegistryFixture();

    await expect(
      registry
        .connect(founder)
        .createOpportunityPassport(
          ethers.ZeroHash,
          "rails://opportunities/1"
        )
    ).to.be.revertedWith("Empty metadata hash");
  });

  it("rejects empty metadata URI", async function () {
    const { founder, registry } = await deployRegistryFixture();

    const metadataHash = ethers.keccak256(
      ethers.toUtf8Bytes("opportunity passport metadata")
    );

    await expect(
      registry
        .connect(founder)
        .createOpportunityPassport(metadataHash, "")
    ).to.be.revertedWith("Empty metadata URI");
  });

  it("rejects unknown passport reads", async function () {
    const { registry } = await deployRegistryFixture();

    await expect(
      registry.getOpportunityPassport(999n)
    ).to.be.revertedWith("Passport not found");
  });

  it("allows owner to update LLM agent id", async function () {
    const { registry } = await deployRegistryFixture();

    const newAgentId = 123n;

    await expect(registry.setLlmAgentId(newAgentId))
      .to.emit(registry, "LlmAgentUpdated")
      .withArgs(12847293847561029384n, newAgentId);

    expect(await registry.llmAgentId()).to.equal(newAgentId);
  });

  it("rejects LLM agent id update from non-owner", async function () {
    const { founder, registry } = await deployRegistryFixture();

    await expect(
      registry.connect(founder).setLlmAgentId(123n)
    ).to.be.revertedWith("Not owner");
  });
});
