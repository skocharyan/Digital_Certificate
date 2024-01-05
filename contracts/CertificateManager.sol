// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract CertificateManager is Ownable {
    // Mapping to store certificate hashes along with their expiration dates
    mapping(bytes32 => uint256) private certificateHashes;

    // Constructor setting the contract owner as the deployer
    constructor() Ownable(msg.sender) {}

    /// @notice Registers a new certificate
    /// @dev This function adds a certificate hash to the certificateHashes mapping.
    /// @param certificateHash The hash of the certificate credentials.
    /// @param expDate Expiration date represented in UTC format.
    function registerCertificate(
        bytes32 certificateHash,
        uint256 expDate
    ) external onlyOwner {
        certificateHashes[certificateHash] = expDate;
    }

    /// @notice Suspends or removes a certificate
    /// @dev This function sets the expiration date of a certificate to zero, deactivating it.
    /// @param certificateHash The hash of the certificate credentials.
    function suspendCertificate(bytes32 certificateHash) external onlyOwner {
        require(
            certificateHashes[certificateHash] > 0,
            "Certificate does not exist"
        );
        certificateHashes[certificateHash] = 0;
    }

    /// @notice Verifies the status of a digital certificate
    /// @dev This function checks the status of a certificate based on its expiration date.
    /// @dev If the UTC date is equal to zero, the certificate is considered expired or deactivated.
    /// @param certificateHash The hash of the certificate credentials.
    /// @return The function returns the certificate status.
    function verifyCertificate(
        bytes32 certificateHash
    ) external view returns (bool) {
        uint256 currentTime = block.timestamp;
        uint256 expirationTime = certificateHashes[certificateHash];

        // Check if the current time is less than the expiration time
        if (currentTime < expirationTime) {
            return true; // Certificate is valid
        }

        return false; // Certificate is expired or deactivated
    }
}
