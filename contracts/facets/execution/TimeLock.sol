// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Multicall} from '../../utils/Multicall.sol';

contract TimeLock is Multicall {
    /// @dev Constants used for gas efficiency.
    uint256 constant MINIMUM_DELAY = 5 minutes;
    uint256 constant MAXIMUM_DELAY = 30 minutes;

    address public base;
    mapping(uint256 => uint256) public proposals;

    modifier onlyBase() {
        require(msg.sender == base, 'Caller is not base.');
        _;
    }

    constructor() {
        base = msg.sender;
    }

    function addProposal(uint256 id, uint256 delay) external onlyBase() {
        require(delay >= MINIMUM_DELAY && delay <= MAXIMUM_DELAY, 'Invalid delay.');
        proposals[id] = block.timestamp + delay;
    }

    function executeProposal(uint256 id, bytes[] calldata data) external onlyBase() {
        require(proposals[id] > 0, 'Not registered.');
        require(proposals[id] < block.timestamp, 'Proposal is not yet executable.');
        this.multicall(data);
    }
}