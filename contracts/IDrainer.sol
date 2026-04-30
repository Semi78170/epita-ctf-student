// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IDrainer {
    /**
     * @notice Initiates the vault exploit sequence and splits proceeds.
     * @param nonce Cryptographic scalar for proof generation.
     */
    function attack(uint256 nonce) external;

    /**
     * @notice Distributes the contract's ETH balance to pre-configured recipients.
     */
    function distribute() external;
}
