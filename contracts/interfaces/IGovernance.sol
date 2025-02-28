// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import '../utils/Types.sol';

interface IGovernance {

    function propose(uint256 time, address[] memory targets, uint[] memory values, bytes4[] memory signatures, bytes[] memory data, string memory description) external returns (uint256);
    function execute(uint256 id) external payable;
    function status(uint256 id) external view returns (ProposalStatus);
    function depositVotes(uint256 id, bool support, uint256 amount) external;
    function withdrawVotes(uint256 id) external;

    function executeProposal(uint256 id) external;
}