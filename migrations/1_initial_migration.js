const Oracle = artifacts.require("Oracle");

module.exports = function (deployer) {
  deployer.deploy(Oracle, "0x1F98431c8aD98523631AE4a59f267346ea31F984");
};
