import hre from "hardhat";
import {abi as BKRegistryABI} from "../artifacts/contracts/BKRegistry.sol/BKRegistry.json";

async function deploy() {
	
	// deploy bkfees
	const BKFeesFactory = await hre.ethers.getContractFactory("BKFees");
	const feeTo = ""
	const altcoinsFeeTo = ""
	const feeRate = "";
	const serverSigner = "";
	const BKFees = await BKFeesFactory.deploy(serverSigner, feeTo, altcoinsFeeTo, feeRate);
	console.log("BKFees: ", BKFees.address);
	
	// deploy registry
	const BKRegistry = await hre.ethers.getContractFactory("BKRegistry");
	const bkRegistry = await BKRegistry.deploy();
	console.log("BitKeepRegistry: ", bkRegistry.address);
	await bkRegistry.deployed();

	// deploy bitswap
	const BKSwapFactory = await hre.ethers.getContractFactory("BKSwap");
	const bkswap = await BKSwapFactory.deploy(bkRegistry.address);
	console.log("BitKeepSwap: ", bkswap.address);

	// delopy aggregationFeature
	await deployAggregationFeature(bkRegistry.address);
}

async function deployAggregationFeature(bkRegistryAddr?: string) {
	if (bkRegistryAddr == "" || bkRegistryAddr == null) {
		bkRegistryAddr = "";
	}
	const AggregationFeatureFactory = await hre.ethers.getContractFactory("AggregationFeature");
	const aggregationFeature = await AggregationFeatureFactory.deploy();
	console.log("AggregationFeature address: ", aggregationFeature.address);

	await aggregationFeature.deployed();
	const bkRegistry = await hre.ethers.getContractAt(BKRegistryABI, bkRegistryAddr);
	await bkRegistry.setFeature("0x6a2b69f0", aggregationFeature.address, true, true);
}


async function main() {
	deploy();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
