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
}