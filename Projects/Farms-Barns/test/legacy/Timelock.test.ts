import { expectRevert, time } from "@openzeppelin/test-helpers";
import { artifacts, contract, ethers } from "hardhat";
import { assert } from "chai";

const WayaToken = artifacts.require("WayaToken");
const TaskMaster = artifacts.require("TaskMaster");
const MockBEP20 = artifacts.require("libs/MockBEP20");
const Timelock = artifacts.require("Timelock");
const SyrupBar = artifacts.require("SyrupBar");

function encodeParameters(types, values) {
  const abi = new ethers.utils.AbiCoder();
  return abi.encode(types, values);
}

contract("Timelock", ([alice, bob, carol, dev, minter]) => {
  let cake, syrup, lp1, chef, timelock;

  beforeEach(async () => {
    cake = await WayaToken.new({ from: alice });
    timelock = await Timelock.new(bob, "28800", { from: alice }); //8hours
  });

  it("should not allow non-owner to do operation", async () => {
    await cake.transferOwnership(timelock.address, { from: alice });
    await expectRevert(cake.transferOwnership(carol, { from: alice }), "Ownable: caller is not the owner");
    await expectRevert(cake.transferOwnership(carol, { from: bob }), "Ownable: caller is not the owner");
    await expectRevert(
      timelock.queueTransaction(
        cake.address,
        "0",
        "transferOwnership(address)",
        encodeParameters(["address"], [carol]),
        (await time.latest()).add(time.duration.hours(6)),
        { from: alice }
      ),
      "Timelock::queueTransaction: Call must come from admin."
    );
  });

  it("should do the timelock thing", async () => {
    await cake.transferOwnership(timelock.address, { from: alice });
    const eta = (await time.latest()).add(time.duration.hours(9));
    await timelock.queueTransaction(
      cake.address,
      "0",
      "transferOwnership(address)",
      encodeParameters(["address"], [carol]),
      eta,
      { from: bob }
    );
    await time.increase(time.duration.hours(1));
    await expectRevert(
      timelock.executeTransaction(
        cake.address,
        "0",
        "transferOwnership(address)",
        encodeParameters(["address"], [carol]),
        eta,
        { from: bob }
      ),
      "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
    );
    await time.increase(time.duration.hours(8));
    await timelock.executeTransaction(
      cake.address,
      "0",
      "transferOwnership(address)",
      encodeParameters(["address"], [carol]),
      eta,
      { from: bob }
    );
    assert.equal((await cake.owner()).valueOf(), carol);
  });

  it("should also work with TaskMaster", async () => {
    lp1 = await MockBEP20.new("LPToken", "LP", "10000000000", { from: minter });
    syrup = await SyrupBar.new(cake.address, { from: minter });
    chef = await TaskMaster.new(cake.address, syrup.address, dev, "1000", "0", { from: alice });
    await cake.transferOwnership(chef.address, { from: alice });
    await syrup.transferOwnership(chef.address, { from: minter });
    await chef.add("100", lp1.address, true, { from: alice });
    await chef.transferOwnership(timelock.address, { from: alice });
    await expectRevert(chef.add("100", lp1.address, true, { from: alice }), "Ownable: caller is not the owner");

    const eta = (await time.latest()).add(time.duration.hours(9));
    await timelock.queueTransaction(
      chef.address,
      "0",
      "transferOwnership(address)",
      encodeParameters(["address"], [minter]),
      eta,
      { from: bob }
    );
    await time.increase(time.duration.hours(9));
    await timelock.executeTransaction(
      chef.address,
      "0",
      "transferOwnership(address)",
      encodeParameters(["address"], [minter]),
      eta,
      { from: bob }
    );
    await expectRevert(chef.add("100", lp1.address, true, { from: alice }), "Ownable: caller is not the owner");
    await chef.add("100", lp1.address, true, { from: minter });
  });
});
