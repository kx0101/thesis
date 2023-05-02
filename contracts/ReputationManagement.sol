pragma solidity ^0.8.17;

contract ReputationManagement {
    struct ReputationScore {
        uint contentQualityScore;
        uint contentPerformanceScore;
        uint communityScore;
    }

    mapping(address => ReputationScore) public reputationScores;

    function updateReputation(
        address artist,
        uint contentQualityScore,
        uint contentPerformanceScore,
        uint communityScore
    ) public {
        ReputationScore storage reputation = reputationScores[artist];

        reputation.contentQualityScore += contentQualityScore;
        reputation.contentPerformanceScore += contentPerformanceScore;
        reputation.communityScore += communityScore;
    }

    function getReputationScore(address artist) public view returns (uint) {
        ReputationScore storage reputation = reputationScores[artist];

        return
            reputation.contentQualityScore +
            reputation.contentPerformanceScore +
            reputation.communityScore;
    }
}
