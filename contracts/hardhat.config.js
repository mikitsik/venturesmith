require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const SOMNIA_RPC_URL =
  process.env.SOMNIA_RPC_URL || "https://api.infra.testnet.somnia.network/";

const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    somniaShannon: {
      url: SOMNIA_RPC_URL,
      chainId: 50312,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
  },
};
