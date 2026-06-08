const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("RawAgentCallbackReceiver", function () {
  async function deployReceiverFixture() {
    const [owner, platform] = await ethers.getSigners();

    const Receiver = await ethers.getContractFactory(
      "RawAgentCallbackReceiver"
    );

    const receiver = await Receiver.deploy();
    await receiver.waitForDeployment();

    return {
      owner,
      platform,
      receiver
    };
  }

  it("stores owner on deploy", async function () {
    const { owner, receiver } = await deployReceiverFixture();

    expect(await receiver.owner()).to.equal(owner.address);
  });

  it("captures raw fallback data", async function () {
    const { platform, receiver } = await deployReceiverFixture();

    const data = "0x12345678deadbeef";

    await platform.sendTransaction({
      to: await receiver.getAddress(),
      data
    });

    expect(await receiver.callbackCount()).to.equal(1n);
    expect(await receiver.lastSender()).to.equal(platform.address);
    expect(await receiver.lastData()).to.equal(data);
  });

  it("increments callback count on every fallback call", async function () {
    const { platform, receiver } = await deployReceiverFixture();

    await platform.sendTransaction({
      to: await receiver.getAddress(),
      data: "0x11111111"
    });

    await platform.sendTransaction({
      to: await receiver.getAddress(),
      data: "0x22222222"
    });

    expect(await receiver.callbackCount()).to.equal(2n);
    expect(await receiver.lastData()).to.equal("0x22222222");
  });

  it("emits CallbackCaptured event", async function () {
    const { platform, receiver } = await deployReceiverFixture();

    const data = "0xabcdef01";

    await expect(
      platform.sendTransaction({
        to: await receiver.getAddress(),
        data
      })
    )
      .to.emit(receiver, "CallbackCaptured")
      .withArgs(platform.address, 1n, data);
  });

  it("accepts plain STT transfers through receive", async function () {
    const { platform, receiver } = await deployReceiverFixture();

    await platform.sendTransaction({
      to: await receiver.getAddress(),
      value: ethers.parseEther("0.01")
    });

    expect(await ethers.provider.getBalance(await receiver.getAddress())).to.eq(
      ethers.parseEther("0.01")
    );

    expect(await receiver.callbackCount()).to.equal(0n);
  });
});
