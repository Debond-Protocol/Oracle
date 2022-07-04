const Oracle = artifacts.require("Oracle");
const governanceOwnable = artifacts.require("governanceOwnable");
module.exports = function (deployer,network,accounts) {
  const UniV3factory = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
  deployer.deploy(governanaceOwnable, accounts[0]);
  deployer.deploy(Oracle,accounts[0]);
};

