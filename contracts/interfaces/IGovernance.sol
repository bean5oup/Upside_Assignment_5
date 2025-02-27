// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import '../utils/Types.sol';

interface IGovernance {

    function propose(uint256 time, address[] memory targets, uint[] memory values, bytes4[] memory signatures, bytes[] memory data, string memory description) external returns (uint256);
    function execute(uint256 id) external payable;
    function status(uint256 id) external view returns (ProposalStatus);
    function vote(uint256 id, bool support) external;

    function addProposal(Proposal memory p) external;
    function executeProposal(uint256 id) external;
}