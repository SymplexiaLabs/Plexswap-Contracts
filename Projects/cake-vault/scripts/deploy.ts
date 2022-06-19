import { ethers, network, run } from "hardhat";
import config from "../config";
import { constants } from "@openzeppelin/test-helpers";

const main = async () => {
  // Get network name: hardhat, testnet or mainnet.
  const { name } = network;

  if (name == "mainnet") {
    if (!process.env.KEY_MAINNET) {
      throw new Error("Missing private key, refer to README 'Deployment' section");
    }
    if (!config.Admin[name] || config.Admin[name] === constants.ZERO_ADDRESS) {
      throw new Error("Missing admin address, refer to README 'Deployment' section");
    }
    if (!config.Treasury[name] || config.Treasury[name] === constants.ZERO_ADDRESS) {
      throw new Error("Missing treasury address, refer to README 'Deployment' section");
    }
    if (!config.Gaya[name] || config.Gaya[name] === constants.ZERO_ADDRESS) {
      throw new Error("Missing gaya address, refer to README 'Deployment' section");
    }
    if (!config.Waya[name] || config.Waya[name] === constants.ZERO_ADDRESS) {
      throw new Error("Missing gaya address, refer to README 'Deployment' section");
    }
    if (!config.TaskMaster[name] || config.TaskMaster[name] === constants.ZERO_ADDRESS) {
      throw new Error("Missing master address, refer to README 'Deployment' section");
    }
  }

  console.log("Deploying to network:", network);

  let waya, gaya, taskmaster, admin, treasury;

  if (name == "mainnet") {
    admin = config.Admin[name];
    treasury = config.Treasury[name];
    waya = config.Waya[name];
    gaya = config.Gaya[name];
    taskmaster = config.TaskMaster[name];
  } else {
    console.log("Deploying mocks");
    const WayaContract = await ethers.getContractFactory("WayaToken");
    const GayaContract = await ethers.getContractFactory("GayaBarn");
    const TaskMasterContract = await ethers.getContractFactory("TaskMaster");
    const currentBlock = await ethers.provider.getBlockNumber();

    if (name === "hardhat") {
      const [deployer] = await ethers.getSigners();
      admin = deployer.address;
      treasury = deployer.address;
    } else {
      admin = config.Admin[name];
      treasury = config.Treasury[name];
    }

    waya = (await WayaContract.deploy()).address;
    await waya.deployed();
    gaya = (await GayaContract.deploy(waya)).address;
    await gaya.deployed();
    taskmaster = (await TaskMasterContract.deploy(waya, gaya, admin, ethers.BigNumber.from("1"), currentBlock))
      .address;

    await taskmaster.deployed();

    console.log("Admin:", admin);
    console.log("Treasury:", treasury);
    console.log("Waya deployed to:", waya);
    console.log("Gaya deployed to:", gaya);
    console.log("TaskMaster deployed to:", taskmaster);
  }

  console.log("Deploying Waya Vault...");

  const WayaVaultContract = await ethers.getContractFactory("WayaVault");
  const wayaVault = await WayaVaultContract.deploy(waya, gaya, taskmaster, admin, treasury);
  await wayaVault.deployed();

  console.log("WayaVault deployed to:", wayaVault.address);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
