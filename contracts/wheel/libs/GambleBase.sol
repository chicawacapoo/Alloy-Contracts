// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract GambleBase {


    modifier noContract() {
        require(msg.sender == tx.origin, "no indirect calls");
        _;
    }

    function rand() internal view returns(uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)) +
            block.number
        )));

        return (seed - ((seed / 1000) * 1000));
    }

}