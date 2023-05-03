pragma solidity ^0.8.0;

import "./ManagementToken.sol";

contract EventTicketing {
    ManagementToken private managementToken;
    uint private ticketPrice;

    struct Event {
        string name;
        mapping(address => uint) ticketsSold;
    }

    mapping(string => Event) events;
    string[] eventNames;

    constructor(address _managementTokenAddress) {
        managementToken = ManagementToken(_managementTokenAddress);
    }

    function setTicketPrice(
        string memory _contentName,
        uint _price,
        address _artist
    ) public {
        require(
            managementToken.tokenExists(_contentName, _artist),
            "EventTicketing: content does not exist"
        );

        ticketPrice = _price;
    }

    function sellTickets(
        string memory _eventName,
        uint _numTickets,
        address _artist
    ) public payable {
        require(
            managementToken.tokenExists(_eventName, _artist),
            "EventTicketing: content does not exist"
        );

        if (bytes(events[_eventName].name).length == 0) {
            events[_eventName].name = _eventName;
            eventNames.push(_eventName);
        }

        events[_eventName].ticketsSold[_artist] += _numTickets;

        (bool success, ) = _artist.call{value: msg.value}("");
        require(success, "EventTicketing: transfer failed");
    }

    function getTicketSales(address _artist) public view returns (uint) {
        uint totalSales;

        for (uint i = 0; i < eventNames.length; i++) {
            totalSales += events[eventNames[i]].ticketsSold[_artist];
        }

        return totalSales;
    }

    function getTicketPrice() public view returns (uint) {
        return ticketPrice;
    }
}
