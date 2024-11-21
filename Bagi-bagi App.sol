// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Giveaway {
    address public owner;
    uint public totalDonations;
    
    mapping(address => uint) public coupons; // Map jumlah kupon setiap pengguna
    mapping(address => bool) public winners; // Map status pemenang
    mapping(address => uint) public claims;  // Map jumlah Ether yang dapat diklaim
    
    event DonationReceived(address indexed donor, uint amount);
    event WinnerAssigned(address indexed winner, uint couponCount);
    event PrizeClaimed(address indexed winner, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyWinner() {
        require(winners[msg.sender], "Only winners can claim their prize");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Fungsi untuk mendonasikan Ether dan mendapatkan kupon
    function donate() external payable {
        require(msg.value > 0, "Donation must be greater than 0");
        coupons[msg.sender] += 1; // Satu donasi setara satu kupon
        totalDonations += msg.value;

        emit DonationReceived(msg.sender, msg.value);
    }

    // Fungsi untuk menentukan pemenang
    function assignWinner(address _winner) external onlyOwner {
        require(coupons[_winner] > 0, "User has no coupons");
        winners[_winner] = true;
        claims[_winner] = coupons[_winner] * 1 ether; // Contoh, 1 kupon setara 1 Ether

        emit WinnerAssigned(_winner, coupons[_winner]);
    }

    // Fungsi bagi pemenang untuk klaim hadiah
    function claimPrize() external onlyWinner {
        uint amount = claims[msg.sender];
        require(amount > 0, "No prize to claim");
        require(address(this).balance >= amount, "Insufficient contract balance");

        claims[msg.sender] = 0; // Set klaim menjadi 0
        winners[msg.sender] = false; // Set status bukan pemenang lagi
        payable(msg.sender).transfer(amount);

        emit PrizeClaimed(msg.sender, amount);
    }

    // Fungsi untuk melihat saldo kontrak
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // Fungsi untuk melihat jumlah kupon user
    function getCoupons(address _user) external view returns (uint) {
        return coupons[_user];
    }
}
