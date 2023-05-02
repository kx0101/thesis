pragma solidity ^0.8.17;

import "./ContentOwnership.sol";

contract ManagementToken {
    address public contentOwnershipAddress;
    mapping(address => mapping(string => bool)) private managementTokens;

    event ManagementTokenCreated(string contentName, address artistAddress);

    event TokensTransferred(
        string contentName,
        address sender,
        address recipient,
        uint256 amount
    );

    constructor(address _contentOwnershipAddress) {
        contentOwnershipAddress = _contentOwnershipAddress;
    }

    function createToken(
        string memory contentName,
        address artistAddress
    ) public {
        ContentOwnership contentOwnership = ContentOwnership(
            contentOwnershipAddress
        );

        require(
            contentOwnership.verifyOwnership(contentName, artistAddress),
            "Artist does not own this content."
        );

        managementTokens[artistAddress][contentName] = true;

        emit ManagementTokenCreated(contentName, artistAddress);
    }

    function tokenExists(
        string memory contentName,
        address artistAddress
    ) public view returns (bool) {
        return managementTokens[artistAddress][contentName];
    }

    function getContentArtist(
        string memory contentName
    ) public view returns (address) {
        ContentOwnership contentOwnership = ContentOwnership(
            contentOwnershipAddress
        );

        return contentOwnership.getContentArtist(contentName);
    }

    function getBalance(address artistAddress) public view returns (uint) {
        return artistAddress.balance;
    }

    function transfer(
        address recipient,
        uint256 amount,
        string memory contentName
    ) public {
        require(getBalance(msg.sender) >= amount, "Insufficient balance.");

        (bool sent, ) = payable(recipient).call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit TokensTransferred(contentName, msg.sender, recipient, amount);
    }
}
