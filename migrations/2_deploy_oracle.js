const Oracle = artifacts.require("Oracle");

module.exports = function (deployer) {
    const owner = ""; // add address of the deployer .
    const uniV3Address = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
  deployer.deploy(Oracle, uniV3Address, owner);

};
