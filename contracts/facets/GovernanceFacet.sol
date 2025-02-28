// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Multicall} from '../utils/Multicall.sol';
import {IGovernance} from '../interfaces/IGovernance.sol';
import {LibDiamond} from '../utils/LibDiamond.sol';
import '../utils/Types.sol';

contract GovernanceFacet is Multicall {
    /// @dev Constants used for gas efficiency.
    uint256 constant MINIMUM_DELTA = 5 minutes;
    uint256 constant MAXIMUM_DELTA = 30 minutes;

    function executeProposal(uint256 id) public payable {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal storage p = local.proposals[id];
        // require(local.proposals[id] > 0, 'Not registered.');
        // require(local.proposals[id] < block.timestamp, 'Proposal is not yet executable.');
        multicall(p.targets, p.values, p.signatures, p.data);
    }

    function propose(uint256 duration, address[] memory targets, uint[] memory values, bytes4[] memory signatures, bytes[] memory data, string memory description) public returns (uint256) {
        require(targets.length != 0);
        require(targets.length == values.length && targets.length == signatures.length && targets.length == data.length, "All arrays must have the same length.");
        
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        
        // check minimum token amount to propose.
        uint256 power = IERC20(local.token).balanceOf(msg.sender);
        require(power > 10, 'Insufficient tokens to propose.');

        require(duration >= MINIMUM_DELTA && duration <= MAXIMUM_DELTA, 'Invalid duration.');
        Proposal storage p = LibDiamond.localStorage().proposals[local.pid];
        p.id = local.pid++;
        p.status = ProposalStatus.Voting;
        p.startTime = block.timestamp;
        p.duration = duration;
        p.executed = false;
        p.proposer = tx.origin;
        p.votesFor = power;
        p.votesAgainst = 0;
        p.targets = targets;
        p.values = values;
        p.signatures = signatures;
        p.data = data;
        p.description = description;
        p.voters[msg.sender] = power;

        return p.id;
    }

    function execute(uint256 id) public payable {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal storage p = local.proposals[id];

        p.status = status(p.id);
        if(p.status == ProposalStatus.Accepted) {
            p.executed = true;
            executeProposal(p.id);
        }
    }

    function status(uint256 id) public view returns (ProposalStatus) {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal storage p = local.proposals[id];

        if (p.executed) {
            return ProposalStatus.Executed;
        } else if (block.timestamp < (p.startTime + p.duration)) {
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

    function depositVotes(uint256 id, bool support, uint256 amount) public {
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal storage p = local.proposals[id];
        require(status(p.id) == ProposalStatus.Voting);
        require(p.voters[msg.sender] == 0, 'Already voted.');

        uint256 power = IERC20(local.token).balanceOf(msg.sender);
        require(amount <= power);

        IERC20(local.token).transferFrom(msg.sender, address(this), amount);
        if(support)
            p.votesFor += amount;
        else
            p.votesAgainst += amount;
        p.voters[msg.sender] = amount;
    }

    function withdrawVotes(uint256 id) public {
        // Checks-Effects-interactions pattern.
        // Pull over push.
        LibDiamond.LocalStorage storage local = LibDiamond.localStorage();
        Proposal storage p = local.proposals[id];
        require(status(p.id) == ProposalStatus.Rejected || status(p.id) == ProposalStatus.Executed);
        uint256 amount = p.voters[msg.sender];
        p.voters[msg.sender] = 0;
        IERC20(local.token).transfer(msg.sender, amount);
    }
}