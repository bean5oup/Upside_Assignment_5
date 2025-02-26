// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title  Multicall
/// @notice Enables calling multiple methods in a single call to the contract
abstract contract Multicall {
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for(uint256 i; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            require(success, 'Multicall failed.');
            results[i] = result;
        }
    }
}