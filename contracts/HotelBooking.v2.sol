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

    // Adds a new room to the hotel inventory (Owner only)
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

    // Allows the owner to safely withdraw contract balance (Checks-Effects-Interactions)
    function withdrawBalance() public onlyOwner {
        uint amount = ownerBalance;
        require(amount > 0, "No funds to withdraw.");

        // Reset owner balance before transfer to prevent reentrancy
        ownerBalance = 0;

        // Transfer funds to the owner
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed.");
    }

    // Read-only view function to inspect room details without incurring gas fees
    function getRoomDetails(uint _roomId) public view returns (string memory name, uint pricePerNight, bool isBooked, address guest) {
        require(_roomId < roomCount, "Invalid room ID.");
        Room memory room = rooms[_roomId];
        return (room.name, room.pricePerNight, room.isBooked, room.currentGuest);
    }


}