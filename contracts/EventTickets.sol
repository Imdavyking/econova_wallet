// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventTickets {
    /// @dev Error for when a function is called by someone who is not the event organizer.
    error EventTickets__NotOrganizer();

    /// @dev Error for when a function is called with an invalid ticket.
    error EventTickets__InvalidTicket();

    /// @dev Error for when a function is called by someone who is not the ticket owner.
    error EventTickets__NotTicketOwner();

    /// @dev Error for when a ticket is being transferred to an invalid address.
    error EventTickets__InvalidAddress();

    /// @dev Error for when the ticket is not listed for sale.
    error EventTickets__NotForSale();

    /// @dev Error for when the value sent does not match the ticket price.
    error EventTickets__IncorrectValue();

    struct Ticket {
        uint256 ticketId;
        uint256 eventId;
        address owner;
        bool isValid;
        bool isForSale;
        uint256 price;
    }

    struct Event {
        uint256 eventId;
        string name;
        string location;
        uint256 date;
        uint256 totalTickets;
        uint256 ticketsSold;
        address organizer;
    }

    uint256 public nextTicketId;
    uint256 public nextEventId;

    mapping(uint256 => Ticket) public tickets;
    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => uint256)) public ticketBalances; // eventId => (owner => ticket count)

    /// @notice Emitted when a new event is created.
    /// @param eventId The ID of the event.
    /// @param name The name of the event.
    /// @param location The location of the event.
    /// @param date The date of the event.
    /// @param totalTickets The total number of tickets available for the event.
    /// @param organizer The address of the event organizer.
    event EventCreated(
        uint256 indexed eventId,
        string name,
        string location,
        uint256 date,
        uint256 totalTickets,
        address indexed organizer
    );

    /// @notice Emitted when a ticket is purchased.
    /// @param ticketId The ID of the ticket.
    /// @param eventId The ID of the event.
    /// @param buyer The address of the ticket buyer.
    /// @param price The price of the ticket.
    event TicketPurchased(
        uint256 indexed ticketId,
        uint256 indexed eventId,
        address indexed buyer,
        uint256 price
    );

    /// @notice Emitted when a ticket is transferred to another user.
    /// @param ticketId The ID of the ticket.
    /// @param from The address of the previous ticket owner.
    /// @param to The address of the new ticket owner.
    event TicketTransferred(
        uint256 indexed ticketId,
        address indexed from,
        address indexed to
    );

    /// @notice Emitted when a ticket is validated by the organizer.
    /// @param ticketId The ID of the ticket.
    /// @param eventId The ID of the event.
    /// @param validator The address of the validator (organizer).
    event TicketValidated(
        uint256 indexed ticketId,
        uint256 indexed eventId,
        address indexed validator
    );

    /// @dev Ensures that only the event organizer can perform certain actions.
    /// @param eventId The ID of the event.
    modifier onlyOrganizer(uint256 eventId) {
        if (events[eventId].organizer != msg.sender) {
            revert EventTickets__NotOrganizer();
        }
        _;
    }

    /// @dev Ensures that the ticket is valid.
    /// @param ticketId The ID of the ticket.
    modifier isTicketValid(uint256 ticketId) {
        if (!tickets[ticketId].isValid) {
            revert EventTickets__InvalidTicket();
        }
        _;
    }

    /// @notice Allows an organizer to create a new event.
    /// @param _name The name of the event.
    /// @param _location The location of the event.
    /// @param _date The date of the event.
    /// @param _totalTickets The total number of tickets available for the event.
    function createEvent(
        string memory _name,
        string memory _location,
        uint256 _date,
        uint256 _totalTickets
    ) public {
        uint256 eventId = nextEventId++;
        events[eventId] = Event(
            eventId,
            _name,
            _location,
            _date,
            _totalTickets,
            0,
            msg.sender
        );

        emit EventCreated(
            eventId,
            _name,
            _location,
            _date,
            _totalTickets,
            msg.sender
        );
    }

    /// @notice Allows a user to purchase a ticket for an event.
    /// @param eventId The ID of the event.
    function purchaseTicket(uint256 eventId) public payable {
        Event storage eventDetail = events[eventId];
        require(eventDetail.totalTickets > eventDetail.ticketsSold, "Sold out");
        require(msg.value > 0, "Ticket price must be greater than zero");

        uint256 ticketId = nextTicketId++;
        tickets[ticketId] = Ticket(
            ticketId,
            eventId,
            msg.sender,
            true,
            false,
            msg.value
        );

        eventDetail.ticketsSold++;
        ticketBalances[eventId][msg.sender]++;

        emit TicketPurchased(ticketId, eventId, msg.sender, msg.value);
    }

    /// @notice Allows the owner of a ticket to transfer it to another user.
    /// @param ticketId The ID of the ticket.
    /// @param to The address of the recipient.
    function transferTicket(
        uint256 ticketId,
        address to
    ) public isTicketValid(ticketId) {
        Ticket storage ticket = tickets[ticketId];
        if (ticket.owner != msg.sender) {
            revert EventTickets__NotTicketOwner();
        }
        if (to == address(0)) {
            revert EventTickets__InvalidAddress();
        }

        ticket.owner = to;
        ticketBalances[ticket.eventId][msg.sender]--;
        ticketBalances[ticket.eventId][to]++;

        emit TicketTransferred(ticketId, msg.sender, to);
    }

    /// @notice Allows the organizer to validate a ticket (e.g., at the event entrance).
    /// @param ticketId The ID of the ticket.
    function validateTicket(
        uint256 ticketId
    ) public onlyOrganizer(tickets[ticketId].eventId) isTicketValid(ticketId) {
        Ticket storage ticket = tickets[ticketId];
        ticket.isValid = false;

        emit TicketValidated(ticketId, ticket.eventId, msg.sender);
    }

    /// @notice Lists a ticket for sale at a specified price.
    /// @param ticketId The ID of the ticket.
    /// @param price The sale price of the ticket.
    function listTicketForSale(
        uint256 ticketId,
        uint256 price
    ) public isTicketValid(ticketId) {
        Ticket storage ticket = tickets[ticketId];
        if (ticket.owner != msg.sender) {
            revert EventTickets__NotTicketOwner();
        }
        require(price > 0, "Price must be greater than zero");

        ticket.isForSale = true;
        ticket.price = price;
    }

    /// @notice Allows a user to purchase a ticket that has been listed for sale.
    /// @param ticketId The ID of the ticket.
    function purchaseListedTicket(
        uint256 ticketId
    ) public payable isTicketValid(ticketId) {
        Ticket storage ticket = tickets[ticketId];
        if (!ticket.isForSale) {
            revert EventTickets__NotForSale();
        }
        if (msg.value != ticket.price) {
            revert EventTickets__IncorrectValue();
        }

        address seller = ticket.owner;
        ticket.owner = msg.sender;
        ticket.isForSale = false;

        payable(seller).transfer(msg.value);

        emit TicketPurchased(ticketId, ticket.eventId, msg.sender, msg.value);
    }
}
