import { expectRevert, time } from "@openzeppelin/test-helpers";
import { artifacts, contract } from "hardhat";
import { assert } from "chai";

const WayaToken = artifacts.require("WayaToken");
const GayaBarn = artifacts.require("GayaBarn");

contract("GayaBarn", ([alice, bob, minter]) => {
  let cake, syrup;

  beforeEach(async () => {
    cake = await WayaToken.new({ from: minter });
    syrup = await GayaBarn.new(cake.address, { from: minter });
  });

  it("mint", async () => {
    await syrup.mint(alice, 1000, { from: minter });
    assert.equal((await syrup.balanceOf(alice)).toString(), "1000");
  });

  it("burn", async () => {
    await time.advanceBlockTo("650");
    await syrup.mint(alice, 1000, { from: minter });
    await syrup.mint(bob, 1000, { from: minter });
    assert.equal((await syrup.totalSupply()).toString(), "2000");
    await syrup.burn(alice, 200, { from: minter });

    assert.equal((await syrup.balanceOf(alice)).toString(), "800");
    assert.equal((await syrup.totalSupply()).toString(), "1800");
  });

  it("safeWayaTransfer", async () => {
    assert.equal((await cake.balanceOf(syrup.address)).toString(), "0");
    await cake.mint(syrup.address, 1000, { from: minter });
    await syrup.safeWayaTransfer(bob, 200, { from: minter });
    assert.equal((await cake.balanceOf(bob)).toString(), "200");
    assert.equal((await cake.balanceOf(syrup.address)).toString(), "800");
    await syrup.safeWayaTransfer(bob, 2000, { from: minter });
    assert.equal((await cake.balanceOf(bob)).toString(), "1000");
  });
});
