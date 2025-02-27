// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// import {Multicall} from '../../utils/Multicall.sol';
import {LibDiamond} from '../../utils/LibDiamond.sol';
import '../../utils/Types.sol';

contract TimeLock {
    /// @dev Constants used for gas efficiency.
    uint256 constant MINIMUM_DELTA = 5 minutes;
    uint256 constant MAXIMUM_DELTA = 30 minutes;

    modifier onlyWorker() {
        require(msg.sender == LibDiamond.localStorage().worker, 'Caller is not a worker.');
        _;
    }

    function addProposal(Proposal memory p) external onlyWorker() {
        require(p.pendingTime >= MINIMUM_DELTA && p.pendingTime <= MAXIMUM_DELTA, 'Invalid delta.');
        LibDiamond.localStorage().proposals[p.id] = p;
    }

    function executeProposal(uint256 id) external onlyWorker() {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal memory p = local.proposals[id];
        // require(local.proposals[id] > 0, 'Not registered.');
        // require(local.proposals[id] < block.timestamp, 'Proposal is not yet executable.');
        // this.multicall(p.targets, p.values, p.signatures, p.data);
    }
}