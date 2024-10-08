// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract Escrow {
    address public depositor;
    address public beneficiary;
    address public arbiter;

    event Approved(uint);

    constructor (address _arbiter, address _beneficiary) payable {
        depositor = msg.sender;
        beneficiary = _beneficiary;
        arbiter = _arbiter;
    }

    function approve() external OnlyArbiter{
        uint balance = address(this).balance;
        (bool s, ) = beneficiary.call{value: balance}("");
        require(s);
        emit Approved(balance);
    }

    modifier OnlyArbiter() {
        require(msg.sender == arbiter);
        _; // Continue executing the function code here
    }


}