pragma solidity ^0.8.17;

contract ContentOwnership {
    struct Content {
        address payable artist;
        string title;
        string description;
        string uri;
        uint price;
        bool isForSale;
    }

    mapping(uint => Content) public contents;

    uint public nextContentId = 0;

    function createContent(
        string memory title,
        string memory description,
        string memory uri,
        uint price
    ) external {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(uri).length > 0, "URI cannot be empty");
        require(price > 0, "Price must be greater than zero");

        contents[nextContentId] = Content(
            payable(msg.sender),
            title,
            description,
            uri,
            price,
            false
        );

        nextContentId++;
    }

    function editContent(
        uint contentId,
        string memory title,
        string memory description,
        string memory uri,
        uint price
    ) external {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(description).length > 0, "Description cannot be empty");
        require(bytes(uri).length > 0, "URI cannot be empty");
        require(price > 0, "Price must be greater than zero");
        require(
            contents[contentId].artist == msg.sender,
            "Only the artist can edit their content"
        );

        contents[contentId].title = title;
        contents[contentId].description = description;
        contents[contentId].uri = uri;
        contents[contentId].price = price;
    }

    function toggleForSale(uint contentId) external {
        require(
            contents[contentId].artist == msg.sender,
            "Only the artist can toggle for sale"
        );
        contents[contentId].isForSale = !contents[contentId].isForSale;
    }

    function purchaseContent(uint contentId) external payable {
        require(contents[contentId].isForSale, "Content is not for sale");
        require(
            msg.value == contents[contentId].price,
            "Incorrect payment amount"
        );

        contents[contentId].artist.transfer(msg.value);
        contents[contentId].isForSale = false;
    }

    function getContentArtist(
        string memory contentName
    ) public view returns (address) {
        for (uint i = 0; i < nextContentId; i++) {
            if (
                keccak256(abi.encodePacked(contents[i].title)) ==
                keccak256(abi.encodePacked(contentName))
            ) {
                return contents[i].artist;
            }
        }
        revert("Content not found");
    }

    function verifyOwnership(
        string memory contentName,
        address artistAddress
    ) public view returns (bool) {
        for (uint i = 0; i < nextContentId; i++) {
            if (
                keccak256(abi.encodePacked(contents[i].title)) ==
                keccak256(abi.encodePacked(contentName)) &&
                contents[i].artist == artistAddress
            ) {
                return true;
            }
        }
        return false;
    }
}
