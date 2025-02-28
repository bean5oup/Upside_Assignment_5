// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @notice The set of possible statuses for a proposal
enum ProposalStatus {
    Voting,
    Accepted,
    Rejected,
    Executed
}

struct Proposal {
    /// @notice 
    uint256 id;

    ProposalStatus status;

    uint256 startTime;

    uint256 duration;
    
    bool executed;

    address proposer;

    uint256 votesFor;

    uint256 votesAgainst;

    address[] targets;

    uint256[] values;

    bytes4[] signatures;

    bytes[] data;

    string description;

    mapping(address => uint256) voters;
}