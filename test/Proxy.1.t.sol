// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

// A -- delegate call --> B -- delegate call -> C
//                        └ ----------- call -> C

contract Proxy is Test{
    PocA A;
    PocB B;
    PocC C;
    
    address player = makeAddr('player');

    constructor() {
        C = new PocC();
        B = new PocB();
        A = new PocA(address(B), address(C));
    }

    function test_Proxy() public {
        vm.startPrank(player);
        console.log('EOA: ', player);
        A.print('A:');
        B.print('B:');
        C.print('C:');
        console.log('----------------');

        // A.proxy_call();
        A.proxy_delegatecall();

        vm.stopPrank();
    }
}

contract PocC {
    function print(string memory name) public view {
        console.log(name);
        console.log('this:      ', address(this));
        console.log('msg.sender:', msg.sender);
    }
}
contract PocB {
    address next_;
    address dummy;
    function print(string memory name) public view {
        console.log(name);
        console.log('this:      ', address(this));
        console.log('msg.sender:', msg.sender);
    }
    function proxy_call() public {
        print('B');
        (bool success, ) = next_.call(abi.encodeWithSignature('print(string)', 'C'));
        require(success);
    }
    function proxy_delegatecall() public {
        print('B');
        (bool success, ) = next_.delegatecall(abi.encodeWithSignature('print(string)', 'C'));
        require(success);
    }
}
contract PocA {
    address C;
    address B;
    constructor(address _B, address _C) {
        B = _B;
        C = _C;
    }
    function print(string memory name) public view {
        console.log(name);
        console.log('this:      ', address(this));
        console.log('msg.sender:', msg.sender);
    }
    function proxy_call() public {
        print('A');
        (bool success, ) = B.call(abi.encodeWithSignature('proxy_call()'));
        require(success);
    }
    function proxy_delegatecall() public {
        print('A');
        (bool success, ) = B.delegatecall(abi.encodeWithSignature('proxy_call()'));
        // (bool success, ) = B.delegatecall(abi.encodeWithSignature('proxy_delegatecall()'));
        require(success);
    }
}