require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: "0.8.20",
  networks: {
    sepolia: {
      url: process.env.RPC_URL,
      accounts: [process.env.CA_PRIVATE_KEY],
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    ganache: {
      url: "http://192.168.1.24:7545", // ✅ Mặc định của Ganache UI
      accounts: [process.env.GANACHE_PRIVATE_KEY], // 🔑 lấy từ Ganache UI
      chainId: 1337, // hoặc 5777 (tuỳ Ganache)
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY, // ✅ KHÔNG còn là object
    customChains: [
      {
        network: "sepolia",
        chainId: 11155111,
        urls: {
          apiURL: "https://api-sepolia.etherscan.io/api",
          browserURL: "https://sepolia.etherscan.io",
        },
      },
    ],
  },
};
