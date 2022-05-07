// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    enum LOTTERY_STATE { OPEN, CLOSED}
    LOTTERY_STATE public state;
    address[] public players;
    constructor() {
        state = LOTTERY_STATE.CLOSED;
    }

    function returnSender() public view returns(address) {
        return msg.sender;
    }

    function stopLottery() public onlyOwner {
        state = LOTTERY_STATE.CLOSED;
    }


    function startLottery() public onlyOwner {
        state = LOTTERY_STATE.OPEN;
        players = new address[](0);
    }

    //will make this payable
    function addPlayers(address[] memory _address) public {
        require(state == LOTTERY_STATE.OPEN, "Lottery is either finished or hasn't begun yet!");
        for(uint i=0; i<_address.length; i++) {
            players.push(_address[i]);
        }
    }

    function declareWinner() public view onlyOwner returns (address) {
        require(state == LOTTERY_STATE.OPEN, "Lottery is either finished or hasn't begun yet!");
        require(players.length > 0, "No players in the lottery Yet!");
        return players[(uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)))) % players.length];
    }

    function resetLottery() public onlyOwner {
        stopLottery();
        players = new address[](0);
    }
}