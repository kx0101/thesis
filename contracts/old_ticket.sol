pragma solidity ^0.8.0;

import "./ManagementToken.sol";

contract oldTicket {
    ManagementToken private managementToken;

    mapping(string => uint256) public ticketPrices;
    mapping(string => uint256) public ticketSales;

    constructor(address _managementTokenAddress) {
        managementToken = ManagementToken(_managementTokenAddress);
    }

    function sellTickets(
        string memory _eventName,
        string memory _contentName,
        uint256 _numTickets,
        address _owner
    ) public {
        require(
            managementToken.tokenExists(_contentName, _owner),
            "You must own the content to sell tickets"
        );
        require(
            ticketPrices[_eventName] > 0,
            "The event must have a ticket price set"
        );

        uint256 cost = ticketPrices[_eventName] * _numTickets;

        require(
            managementToken.getBalance(msg.sender) >= cost,
            "You do not have enough tokens to sell that many tickets"
        );

        ticketSales[_eventName] += _numTickets;
        managementToken.transfer(_owner, cost, _contentName);
    }

    function setTicketPrice(string memory _eventName, uint256 _price) public {
        require(
            managementToken.getBalance(msg.sender) > 0,
            "You must own management tokens to set a ticket price"
        );

        ticketPrices[_eventName] = _price;
    }

    function getSales(string memory _eventName) public view returns (uint256) {
        return ticketSales[_eventName];
    }
}
