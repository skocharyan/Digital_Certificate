const CertificateManager = artifacts.require("CertificateManager");

contract("CertificateManager", (accounts) => {
  let certificateManagerInstance;
  const certificateObject = {
    firstName: "John",
    lastName: "Doe",
    organizationName: "Example Corp",
    issueDate: "2024-01-05", // Assuming a string representation of the date
    expirationDate: "2025-01-05", // Assuming a string representation of the date
    number: "ABC123456",
  };

  before(async () => {
    // Deploy the CertificateManager contract before running the tests
    certificateManagerInstance = await CertificateManager.deployed();
  });

  it("should register a certificate and verify its status", async () => {
    const certificateHash = web3.utils.keccak256(
      JSON.stringify(certificateObject)
    );
    const expirationDate = Math.floor(Date.now() / 1000) + 3600; // Set expiration to 1 hour from now

    // Register a certificate
    await certificateManagerInstance.registerCertificate(
      certificateHash,
      expirationDate
    );

    // Verify the certificate status
    const isCertificateValid =
      await certificateManagerInstance.verifyCertificate(certificateHash);

    assert.isTrue(isCertificateValid, "Certificate should be valid");
  });

  it("should suspend a certificate and verify its status", async () => {
    const certificateHash = web3.utils.keccak256(
      JSON.stringify(certificateObject)
    );

    // Suspend the certificate
    await certificateManagerInstance.suspendCertificate(certificateHash);

    // Verify the certificate status after suspension
    const isCertificateValid =
      await certificateManagerInstance.verifyCertificate(certificateHash);

    assert.isFalse(isCertificateValid, "Certificate should be suspended");
  });
});
