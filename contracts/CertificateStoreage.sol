// SPDX-License-Identifier: MIT

pragma solidity >=0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title CertificateStorage - Manage Digital Certificates
/// @notice This smart contract offers secure creation, verification, and management of digital certificates.
/// @notice It utilizes on-chain storage for sensitive information to enhance security and privacy.
contract CertificateStorage is Ownable {
    event CertificateRegistered(bytes32 certificateHash);

    event Log(string, uint256);

    struct Certificate {
        string firstName;
        string lastName;
        string orgName;
        uint256 issuedDate;
        uint256 expirationDate;
    }

    // Mapping to store certificate hashes along with their expiration dates
    mapping(bytes32 => Certificate) private certificateHashes;

    // Constructor setting the contract owner as the deployer
    constructor() Ownable(msg.sender) {}

    /// @notice Creates a certificate based on credentials
    /// @dev The function creates a certificate object and its hash.
    /// @dev Further, the certificate hash is used as a key to store the certificate.
    /// @param firstName Certificate owner's first name.
    /// @param lastName Certificate owner's last name.
    /// @param orgName Certification organization name.
    /// @param issuedDate Issued date.
    /// @param expirationDate Expiration date.
    function createCertificate(
        string calldata firstName,
        string calldata lastName,
        string calldata orgName,
        uint256 issuedDate,
        uint256 expirationDate
    ) external onlyOwner {
        Certificate memory certificate = Certificate({
            firstName: firstName,
            lastName: lastName,
            orgName: orgName,
            issuedDate: issuedDate,
            expirationDate: expirationDate
        });

        bytes32 certificateHash = keccak256(
            abi.encode(firstName, lastName, orgName, issuedDate, expirationDate)
        );
        certificateHashes[certificateHash] = certificate;
        emit CertificateRegistered(certificateHash);
    }

    /// @notice Verifies the certificate's validity by hash
    /// @dev Checks if the certificate has expired.
    /// @param certificateHash The hash of the certificate to be verified.
    /// @return True if the certificate is valid, false otherwise.
    function verifyByHash(bytes32 certificateHash) public view returns (bool) {
        if (
            certificateHashes[certificateHash].expirationDate < block.timestamp
        ) {
            return false;
        }
        return true;
    }

    /// @notice Verifies the certificate's validity by credentials
    /// @dev Generates a hash from provided credentials and calls verifyByHash.
    /// @param firstName Certificate owner's first name.
    /// @param lastName Certificate owner's last name.
    /// @param orgName Certification organization name.
    /// @param issuedDate Issued date.
    /// @param expirationDate Expiration date.
    /// @return True if the certificate is valid, false otherwise.
    function verifyByCredentials(
        string calldata firstName,
        string calldata lastName,
        string calldata orgName,
        uint256 issuedDate,
        uint256 expirationDate
    ) external view returns (bool) {
        bytes32 credentialsHash = keccak256(
            abi.encode(firstName, lastName, orgName, issuedDate, expirationDate)
        );
        return verifyByHash(credentialsHash);
    }

    /// @notice Suspends a certificate by hash
    /// @dev Checks if the certificate is currently active and deletes it.
    /// @param credentialHash The hash of the certificate to be suspended.
    function suspendByHash(bytes32 credentialHash) public onlyOwner {
        require(
            certificateHashes[credentialHash].expirationDate >= block.timestamp,
            "Certificate is not active"
        );
        delete certificateHashes[credentialHash];
    }

    /// @notice Suspends a certificate by credentials
    /// @dev Generates a hash from provided credentials and calls suspendByHash.
    /// @param firstName Certificate owner's first name.
    /// @param lastName Certificate owner's last name.
    /// @param orgName Certification organization name.
    /// @param issuedDate Issued date.
    /// @param expirationDate Expiration date.
    function suspendByCredentials(
        string calldata firstName,
        string calldata lastName,
        string calldata orgName,
        uint256 issuedDate,
        uint256 expirationDate
    ) external onlyOwner {
        bytes32 credentialsHash = keccak256(
            abi.encode(firstName, lastName, orgName, issuedDate, expirationDate)
        );
        suspendByHash(credentialsHash);
    }
}
