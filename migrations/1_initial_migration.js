const Oracle = artifacts.require("Oracle");

module.exports = function (deployer) {
  deployer.deploy(Oracle, "0x1F98431c8aD98523631AE4a59f267346ea31F984", "0xAf534ebB10Ba9cB7aCA13B39a119381Ff5E8d8Ba");
};
