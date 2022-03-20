const LarioToken = artifacts.require("LarioToken");

module.exports = function (deployer) {
  deployer.deploy(LarioToken);
};
