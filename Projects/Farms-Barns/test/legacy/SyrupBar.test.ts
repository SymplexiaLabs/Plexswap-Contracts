import { expectRevert, time } from "@openzeppelin/test-helpers";
import { artifacts, contract } from "hardhat";
import { assert } from "chai";

const WayaToken = artifacts.require("WayaToken");
const GayaBarn = artifacts.require("GayaBarn");

contract("GayaBarn", ([alice, bob, minter]) => {
  let waya, gaya;

  beforeEach(async () => {
    waya = await WayaToken.new({ from: minter });
    gaya = await GayaBarn.new(waya.address, { from: minter });
  });

  it("mint", async () => {
    await gaya.mint(alice, 1000, { from: minter });
    assert.equal((await gaya.balanceOf(alice)).toString(), "1000");
  });

  it("burn", async () => {
    await time.advanceBlockTo("650");
    await gaya.mint(alice, 1000, { from: minter });
    await gaya.mint(bob, 1000, { from: minter });
    assert.equal((await gaya.totalSupply()).toString(), "2000");
    await gaya.burn(alice, 200, { from: minter });

    assert.equal((await gaya.balanceOf(alice)).toString(), "800");
    assert.equal((await gaya.totalSupply()).toString(), "1800");
  });

  it("safeWayaTransfer", async () => {
    assert.equal((await waya.balanceOf(gaya.address)).toString(), "0");
    await waya.mint(gaya.address, 1000, { from: minter });
    await gaya.safeWayaTransfer(bob, 200, { from: minter });
    assert.equal((await waya.balanceOf(bob)).toString(), "200");
    assert.equal((await waya.balanceOf(gaya.address)).toString(), "800");
    await gaya.safeWayaTransfer(bob, 2000, { from: minter });
    assert.equal((await waya.balanceOf(bob)).toString(), "1000");
  });
});
