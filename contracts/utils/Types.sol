// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @notice The set of possible statuses for a proposal
enum ProposalStatus {
    Pending,
    Executed,
    Canceled
}

struct Proposal {
    /// @notice 
    uint256 id;

    uint256 startBlock;

    address proposer;

    uint256 votesFor;

    uint256 votesAgainst;

    address[] targets;

    uint256[] values;

    string[] signatures;

    bytes[] data;
}