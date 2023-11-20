var RampService = artifacts.require("./RampService.sol");

module.exports = function(deployer) {
  deployer.deploy(RampService);
};
