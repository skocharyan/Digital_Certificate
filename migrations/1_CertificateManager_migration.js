const CertificateManager = artifacts.require("CertificateManager");

module.exports = function (deployer) {
  deployer.deploy(CertificateManager);
};
