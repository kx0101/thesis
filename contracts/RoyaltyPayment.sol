pragma solidity ^0.8.17;

contract RoyaltyPayment {
    address payable public artist;

    uint public royaltyPercentage;
    uint public totalStreams;
    uint public royaltyAmount;

    constructor(address payable _artist, uint _royaltyPercentage) {
        artist = _artist;
        royaltyPercentage = _royaltyPercentage;
    }

    function addStreams(uint streams, address _artist) external {
        require(_artist == artist, "Only the artist can add streams");
        totalStreams += streams;
        royaltyAmount = (totalStreams * royaltyPercentage) / 100;
    }

    function withdraw() external {
        require(msg.sender == artist, "Only the artist can withdraw royalties");
        require(royaltyAmount > 0, "No royalties available");
        artist.transfer(royaltyAmount);

        royaltyAmount = 0;
    }

    function getRoyaltyPayment() external view returns (uint) {
        return royaltyAmount;
    }
}
