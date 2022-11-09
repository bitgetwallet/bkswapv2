import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomiclabs/hardhat-ethers";
import "hardhat-gas-reporter";
import * as dotenv from "dotenv";
dotenv.config();

const { ALCHEMY_API_KEY, MAINNET_KEY } = process.env;

const config: HardhatUserConfig = {
	defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            forking: {
                enabled: true,
                url: "https://eth-mainnet.alchemyapi.io/v2/" + ALCHEMY_API_KEY,
            },
            chainId: 1,
        },
        eth_mainnet: {
            url: "https://eth-mainnet.alchemyapi.io/v2/" + ALCHEMY_API_KEY,
            accounts: [MAINNET_KEY]
        },
        polygon_mainnet: {
            url: "https://polygon-mainnet.g.alchemy.com/v2/" + ALCHEMY_API_KEY,
            accounts: [MAINNET_KEY],
            chainId: 137
        },
        arb_mainnet: {
            url: "https://arb-mainnet.g.alchemy.com/v2/" + ALCHEMY_API_KEY,
            accounts: [MAINNET_KEY]
        },
        op_mainnet: {
            url: "https://opt-mainnet.g.alchemy.com/v2/" + ALCHEMY_API_KEY,
            accounts: [MAINNET_KEY]
        },
        bsc_mainnet: {
            url: "https://bsc-dataseed.binance.org/",
            chainId: 56,
            accounts: [MAINNET_KEY]
        },
        heco_mainnet: {
            url: "https://http-mainnet.hecochain.com",
            chainId: 128,
            accounts: [MAINNET_KEY]
        },
        okc_mainnet: {
            url: "https://exchainrpc.okex.org",
            chainId: 66,
            accounts: [MAINNET_KEY]
        },
        ftm_mainnet: {
            url: "https://rpc.ftm.tools",
            accounts: [MAINNET_KEY]
        },
        avax_mainnet: {
            url: "https://api.avax.network/ext/bc/C/rpc",
            accounts: [MAINNET_KEY]
        },
        cro_mainnet: {
            url: "https://evm.cronos.org",
            accounts: [MAINNET_KEY],
        },
        boba_mainnet: {
            url: "https://mainnet.boba.network",
            chainId: 288,
            accounts: [MAINNET_KEY],
        },
        aurora_mainnet: {
            url: "https://mainnet.aurora.dev",
            chainId: 1313161554,
            accounts: [MAINNET_KEY],
        },
        celo_mainnet: {
            url: "https://rpc.ankr.com/celo",
            chainId: 42220,
            accounts: [process.env.MAINNET_KEY],
        },
    },
	gasReporter: {
        enabled: true,
        gasPrice: 21,
        currency: "USD",
        showMethodSig: true
	},
	solidity: {
        compilers: [
            {
                version: "0.8.17"
            }
        ],
        settings: {
            optimizer: {
                enabled: true,
                runs: 10000,
                details: {
                    yul: false
                }
            }
        }
    },
    mocha:{
        timeout:1000000000
    }
};

export default config;
