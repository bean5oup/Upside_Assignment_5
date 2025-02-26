// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {LibDiamond} from '../../utils/LibDiamond.sol';
import '../../utils/Types.sol';
import './TimeLock.sol';

contract GovernanceFacet is TimeLock {
    constructor() {
        
    }

    function propose(uint256 time, address[] memory targets, uint[] memory values, string[] memory signatures, bytes[] memory data, string memory description) public returns (uint256) {
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
        p.votesFor = 0;
        p.votesAgainst = 0;
        p.targets = targets;
        p.values = values;
        p.signatures = signatures;
        p.data = data;
        p.description = description;

        local.activeProposals.push(p.id);

        this.addProposal(p);
        
        return p.id;
    }

    function execute(uint256 id) public payable {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal memory p = local.proposals[id];

        p.status = status(p.id);
        require(p.status == ProposalStatus.Accepted);

        p.executed = true;
        this.executeProposal(p.id);
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

    function vote() public {

    }
}