// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

/// @title  Multicall
/// @notice Enables calling multiple methods in a single call to the contract
abstract contract Multicall {
    function multicall(address[] memory targets, uint256[] memory values, bytes4[] memory signatures, bytes[] memory data) public payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for(uint256 i; i < data.length; i++) {
            // (bool success, bytes memory result) = targets[i].delegatecall(abi.encodeWithSignature(signatures[i], data[i]));
            (bool success, bytes memory result) = targets[i].call{value: values[i]}(abi.encodePacked(signatures[i], data[i]));
            require(success, 'Multicall failed.');
            results[i] = result;
        }
    }
}