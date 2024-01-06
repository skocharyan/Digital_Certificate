const CertificateStorage = artifacts.require("CertificateStorage");

contract("CertificateStorage", (accounts) => {
  let certificateStorage;

  before(async () => {
    certificateStorage = await CertificateStorage.deployed();
  });

  it("should create a certificate and emit an event", async () => {
    const result = await certificateStorage.createCertificate(
      "John",
      "Doe",
      "CertOrg",
      1699788800, // May 12, 2023 (GMT)
      1765340800 // December 12, 2023 (GMT)
    );

    const certificateHash = result.logs[0].args.certificateHash;

    // Create the expected certificate hash using the correct encoding
    const expectedCertificateHash = web3.utils.keccak256(
      web3.eth.abi.encodeParameters(
        ["string", "string", "string", "uint256", "uint256"],
        ["John", "Doe", "CertOrg", 1699788800, 1765340800]
      )
    );

    assert.equal(
      certificateHash,
      expectedCertificateHash,
      "Certificate creation failed"
    );
  });

  it("should verify the certificate by hash", async () => {
    const result = await certificateStorage.createCertificate(
      "Alice",
      "Smith",
      "OrgXYZ",
      1699788800,
      1765340800
    );

    const certificateHash = result.logs[0].args.certificateHash.toString(); // Ensure it's a string

    const isValid = await certificateStorage.verifyByHash(certificateHash);
    assert.isTrue(isValid, "Certificate verification by hash failed");
  });

  it("should verify the certificate by credentials", async () => {
    const isValid = await certificateStorage.verifyByCredentials(
      "Alice",
      "Smith",
      "OrgXYZ",
      1699788800,
      1765340800
    );

    assert.isTrue(isValid, "Certificate verification by credentials failed");
  });

  it("should suspend the certificate by hash", async () => {
    // Create a certificate and obtain the certificateHash
    const createResult = await certificateStorage.createCertificate(
      "Bob",
      "Johnson",
      "CertCorp",
      1699788800,
      1765340800
    );
    const certificateHash =
      createResult.logs[0].args.certificateHash.toString();

    // Suspend the certificate by hash
    await certificateStorage.suspendByHash(certificateHash);
    // Check if the certificate is suspended
    const status = await certificateStorage.verifyByHash(certificateHash);
    assert.isFalse(status, "Certificate suspension failed");
  });

  it("should suspend the certificate by credentials", async () => {
    await certificateStorage.createCertificate(
      "Eve",
      "Adams",
      "Org123",
      1699788800,
      1765340800
    );

    await certificateStorage.suspendByCredentials(
      "Eve",
      "Adams",
      "Org123",
      1699788800,
      1765340800
    );

    const status = await certificateStorage.verifyByCredentials(
      "Eve",
      "Adams",
      "Org123",
      1699788800,
      1765340800
    );

    assert.isFalse(status, "Certificate suspension failed");
  });
});
