// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import {Multicall} from '../utils/Multicall.sol';
import {IGovernance} from '../interfaces/IGovernance.sol';
import {LibDiamond} from '../utils/LibDiamond.sol';
import '../utils/Types.sol';

contract GovernanceFacet is Multicall {
    /// @dev Constants used for gas efficiency.
    uint256 constant MINIMUM_DELTA = 5 minutes;
    uint256 constant MAXIMUM_DELTA = 30 minutes;

    constructor() {
        
    }

    function addProposal(Proposal memory p) public {
        require(p.pendingTime >= MINIMUM_DELTA && p.pendingTime <= MAXIMUM_DELTA, 'Invalid delta.');
        LibDiamond.localStorage().proposals[p.id] = p;
    }

    function executeProposal(uint256 id) public payable {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal memory p = local.proposals[id];
        // require(local.proposals[id] > 0, 'Not registered.');
        // require(local.proposals[id] < block.timestamp, 'Proposal is not yet executable.');
        multicall(p.targets, p.values, p.signatures, p.data);
    }

    function propose(uint256 time, address[] memory targets, uint[] memory values, bytes4[] memory signatures, bytes[] memory data, string memory description) public returns (uint256) {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        // check minimum token amount to propose.
        // require();
        require(targets.length != 0);
        require(targets.length == values.length && targets.length == signatures.length && targets.length == data.length, "All arrays must have the same length.");
        
        Proposal memory p;
        p.id = local.pid++;
        p.status = ProposalStatus.Voting;
        p.startTime = block.timestamp;
        p.pendingTime = time;
        p.executed = false;
        p.proposer = tx.origin;
        p.votesFor = 1;
        p.votesAgainst = 0;
        p.targets = targets;
        p.values = values;
        p.signatures = signatures;
        p.data = data;
        p.description = description;

        addProposal(p);
        
        return p.id;
    }

    function execute(uint256 id) public payable {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal memory p = local.proposals[id];

        p.status = status(p.id);
        if(p.status == ProposalStatus.Accepted) {
            p.executed = true;
            executeProposal(p.id);
        }
    }

    function status(uint256 id) public view returns (ProposalStatus) {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal memory p = local.proposals[id];

        if (p.executed) {
            return ProposalStatus.Executed;
        } else if (block.timestamp < (p.startTime + p.pendingTime)) {
            return ProposalStatus.Voting;
        }

        uint256 total = p.votesFor + p.votesAgainst;
        bool accepted = (p.votesFor / total * 100) >= 67 ? true : false;
        
        if (accepted) {
            return ProposalStatus.Accepted;
        } else {
            return ProposalStatus.Rejected;
        }
    }

    function vote(uint256 id, bool support) public {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal memory p = local.proposals[id];
        require(status(p.id) == ProposalStatus.Voting);
    }
}