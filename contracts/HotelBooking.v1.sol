// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Defining the HotelBooking contract
contract HotelBooking {
    // State variables for contract management and accounting
    address public owner;
    uint public ownerBalance;

    // Struct to store room information and booking state
    struct Room {
        string name;
        uint pricePerNight;
        bool isBooked;
        address currentGuest;
    }

    // Mapping to store rooms using a unique ID
    mapping(uint => Room) public rooms;
    uint public roomCount;

    // Events emitted for off-chain logging and transparency
    event RoomAdded(uint roomId, string name, uint pricePerNight);
    event RoomBooked(address customer, uint roomId, uint nights, uint totalCost);
    event PaymentReceived(address customer, uint amount);

    // Access control modifier restricting functions to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // Constructor executed once upon contract deployment
    constructor() {
        owner = msg.sender;
    }

    // Add a new room to the hotel inventory (Owner only)
    function addRoom(string memory _name, uint _pricePerNight) public onlyOwner {
        roomCount++;
        rooms[roomCount] = Room(_name, _pricePerNight, false, address(0));
        emit RoomAdded(roomCount, _name, _pricePerNight);
    }

    // Book a room for a specific number of nights by transferring exact Ether
    function bookRoom(uint _roomId, uint _nights) public payable {
       
        Room storage room = rooms[_roomId];
        require(_roomId < roomCount, "Invalid room ID.");
        require(!room.isBooked, "Room is already booked.");
        require(_nights > 0, "Nights must be at least 1.");

        uint totalCost = room.pricePerNight * _nights;
        require(msg.value == totalCost, "Incorrect payment amount.");

        // Update room state and owner balance
        room.isBooked = true;
        room.guest = msg.sender;
        ownerBalance += msg.value;

        // Emit logging events
        emit RoomBooked(msg.sender, _roomId, _nights, totalCost);
        emit PaymentReceived(msg.sender, msg.value);
    }

}