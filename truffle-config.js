require("ts-node").register({files: true});
const HDWalletProvider = require("@truffle/hdwallet-provider");
require('dotenv').config();
const Web3 = require("web3");
const web3 = new Web3();

module.exports = {
  plugins: ['truffle-plugin-verify'],
  api_keys: {
    etherscan: process.env.ETHERSCAN_API_KEY,
    polygonscan : process.env.POLYGONSCAN_API_KEY
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      gas: 3500000
    },
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, `https://rinkeby.infura.io/v3/${process.env.INFURA_Access_Token}`);
      },
      network_id: 4,
      // gas: 30000000, //from ganache-cli output
      // gasPrice: web3.utils.toWei('1', 'gwei')
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, `https://ropsten.infura.io/v3/${process.env.INFURA_Access_Token}`);
      },
      network_id: 3,
      // gas: 30000000, //from ganache-cli output
      gasPrice: web3.utils.toWei('1', 'gwei')
    },
    matic: {
      provider: () => new HDWalletProvider(process.env.TESTNET_PRIVATE_KEY, `wss://polygon-mainnet.g.alchemy.com/v2/${process.env.MAINNET_POLYGON_KEY}`),
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      gasPrice: web3.utils.toWei('100', 'gwei'),
      gas: 3000000,
      skipDryRun: true
    }
  },
  mocha: {
     reporter: 'eth-gas-reporter',
  },
  compilers: {
    solc: {
      version: "0.7.6",
      settings: { // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        }
      },
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
