const { ethers } = require("hardhat");
const assert = require("assert");

describe("BlockchainMusicApp", function() {
    let contentOwnership, managementToken, royaltyPayment, eventTicketing, reputationManagement;

    before(async function() {
        // Deploy content ownership contract
        const ContentOwnership = await ethers.getContractFactory("ContentOwnership");
        contentOwnership = await ContentOwnership.deploy();

        // Deploy management token contract
        const ManagementToken = await ethers.getContractFactory("ManagementToken");
        managementToken = await ManagementToken.deploy(contentOwnership.address);

        // Deploy royalty payment contract
        const RoyaltyPayment = await ethers.getContractFactory("RoyaltyPayment");
        royaltyPayment = await RoyaltyPayment.deploy(managementToken.address, 10);

        // Deploy event ticketing contract
        const EventTicketing = await ethers.getContractFactory("EventTicketing");
        eventTicketing = await EventTicketing.deploy(managementToken.address);

        // Deploy reputation management contract
        const ReputationManagement = await ethers.getContractFactory("ReputationManagement");
        reputationManagement = await ReputationManagement.deploy();
    });

    it("should create a management token for a piece of content", async function() {
        // Register a new piece of content with the content ownership contract
        await contentOwnership.createContent("My Awesome Song", "My Awesome Lyrics", "My Awesome Album", 100);

        // Get the token ID of the content
        const tokenId = await contentOwnership.getTokenId(0);

        // Verify that a valid token ID is being returned
        assert.equal(tokenId, 0);

        // Verify ownership of the content
        assert(await contentOwnership.verifyOwnership("My Awesome Song", ethers.provider.getSigner(0).getAddress()) === true);

        // Create a management token for the content
        await managementToken.createToken("My Awesome Song", ethers.provider.getSigner(0).getAddress());

        // Verify that the management token was created
        assert(await managementToken.tokenExists("My Awesome Song", ethers.provider.getSigner(0).getAddress()) === true);
    });

    it("should distribute royalties to artists based on concert performance", async function() {
        // Register a new piece of content with the content ownership contract
        await contentOwnership.createContent("My Concert", "My Awesome Lyrics", "My Awesome Album", 100);

        // Verify ownership of the content
        assert(await contentOwnership.verifyOwnership("My Concert", ethers.provider.getSigner(0).getAddress()) === true);

        // Create a management token for the content
        await managementToken.createToken("My Concert", ethers.provider.getSigner(0).getAddress());

        // Verify that the management token was created
        assert(await managementToken.tokenExists("My Concert", ethers.provider.getSigner(0).getAddress()) === true);

        // Sell some copies of the content
        await eventTicketing.setTicketPrice("My Concert", 10, ethers.provider.getSigner(0).getAddress());
        await eventTicketing.sellTickets("My Concert", 100, ethers.provider.getSigner(0).getAddress());

        // Verify that the ticket price was set correctly
        assert.equal((await eventTicketing.getTicketPrice()).toNumber(), 10);

        // Verify that the artist's ticket sales were updated correctly
        assert.equal((await eventTicketing.getTicketSales(ethers.provider.getSigner(0).getAddress())).toNumber(), 100);
    });

    it("should update an artist's reputation score based on the performance of their streams.", async function() {
        // Register a new piece of content with the content ownership contract
        await contentOwnership.createContent("My Awesome Song", "My Awesome Lyrics", "My Awesome Album", 100);

        // Verify ownership of the content
        assert(await contentOwnership.verifyOwnership("My Awesome Song", ethers.provider.getSigner(0).getAddress()) === true);

        // Create a management token for the content
        await managementToken.createToken("My Awesome Song", ethers.provider.getSigner(0).getAddress());

        // Verify that the management token was created
        assert(await managementToken.tokenExists("My Awesome Song", ethers.provider.getSigner(0).getAddress()) === true);

        // Check that the correct amount of royalties were paid to the artist
        await royaltyPayment.addStreams(1000, managementToken.address);

        const totalRoyaltyPayment = await royaltyPayment.getRoyaltyPayment();
        const totalRoyaltyPaymentNumber = totalRoyaltyPayment.toNumber();

        // Assert that the royalty payment is equal to 100
        assert.equal(totalRoyaltyPaymentNumber, 100)

        // Update the artist's reputation score
        await reputationManagement.updateReputation(ethers.provider.getSigner(0).getAddress(), 10, 10, 10);

        // Verify that the artist's reputation score was updated
        const totalScoreBig = await reputationManagement.getReputationScore(ethers.provider.getSigner(0).getAddress());
        const totalScore = totalScoreBig.toNumber();

        // Assert that the total score of the artist is equal to 30
        assert.equal(totalScore, 30)

    });
});
