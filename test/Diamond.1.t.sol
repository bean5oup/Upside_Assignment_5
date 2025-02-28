// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import 'forge-std/Test.sol';

import {LibDiamond} from '../contracts/utils/LibDiamond.sol';
import '../contracts/interfaces/IDiamondLoupe.sol';
import '../contracts/facets/GovernanceFacet.sol';
import '../contracts/Base.sol';

contract PublicTest1 is Test {
    address deployer = makeAddr('deployer');
    address player = makeAddr('player');
    address voter = makeAddr('voter');

    address public governance;
    address public token_;

    constructor() {
        vm.startPrank(deployer);
        TestToken token = new TestToken(deployer);
        governance = address(new Base(address(token)));
        token.setOwner(governance);
        token_ = address(token);
        vm.stopPrank();
        console.log('deployer:   ', deployer);
        console.log('player:     ', player);
        console.log('governance: ', governance);
        console.log('token:      ', token_);
        console.log('');
    }

    function test_RevertWhen_DirectAccess() public {
        address testFacet = address(new TestFacet());

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = 0x12345678;

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: testFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        vm.expectRevert();
        IDiamondCut(governance).diamondCut(cut, address(0), '');
    }

    function test_Deploy() public {
        // address token = address(new TestToken(governance));
        vm.startPrank(governance);
        TestToken(token_).mint(player, 11);
        vm.stopPrank();

        vm.startPrank(player);
        address[] memory targets = new address[](1);
        targets[0] = token_;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = bytes4(keccak256('t1()'));

        bytes[] memory data = new bytes[](1);
        data[0] = '';

        uint256 id = GovernanceFacet(governance).propose(5 minutes, targets, values, signatures, data, 'test');

        GovernanceFacet(governance).execute(id);

        vm.warp(block.timestamp + 6 minutes);
        GovernanceFacet(governance).execute(id);
        vm.stopPrank();
    }

    function test_RevertWhen_AddTokenFacet8CallMintDirectly() public {
        vm.startPrank(governance);
        TestToken(token_).mint(player, 11);
        vm.stopPrank();

        // Add the token contract as a facet so that its mint() can be used arbitrarily.
        // address token = address(new TestToken(governance));

        vm.startPrank(player);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = bytes4(keccak256('t1()'));

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: token_,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        address[] memory targets = new address[](1);
        targets[0] = governance;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = IDiamondCut.diamondCut.selector;

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(cut, address(0), '');

        uint256 id = GovernanceFacet(governance).propose(5 minutes, targets, values, signatures, data, 'test');

        GovernanceFacet(governance).execute(id);

        vm.warp(block.timestamp + 6 minutes);
        GovernanceFacet(governance).execute(id);

        // GovernanceFacet(governance).mint();
        vm.expectRevert();
        (bool success, ) = governance.call(abi.encodeWithSignature('t1()'));
        require(success);
        vm.stopPrank();
    }

    function test_SetWorker() public {
        vm.startPrank(governance);
        TestToken(token_).mint(player, 11);
        vm.stopPrank();

        vm.startPrank(player);
        
        // address diamondCutFacet = IDiamondLoupe(governance).facetAddress(IDiamondCut.diamondCut.selector);
        address testFacet = address(new TestFacet());
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = bytes4(keccak256('setWorker(address)'));

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: testFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        address[] memory targets = new address[](1);
        targets[0] = governance;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = IDiamondCut.diamondCut.selector;

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(cut, address(0), '');

        uint256 id = GovernanceFacet(governance).propose(5 minutes, targets, values, signatures, data, 'test');

        GovernanceFacet(governance).execute(id);

        vm.warp(block.timestamp + 6 minutes);
        GovernanceFacet(governance).execute(id);

        (bool success, ) = governance.call(abi.encodeWithSignature('setWorker(address)', player));
        require(success);

        IDiamondCut.FacetCut[] memory cut2 = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors2 = new bytes4[](1);
        functionSelectors2[0] = 0x12345678;

        cut2[0] = IDiamondCut.FacetCut({
            facetAddress: testFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors2
        });

        IDiamondCut(governance).diamondCut(cut2, address(0), '');

        vm.stopPrank();
    }

    function test_RevertWhen_CallRemovedFacetFunc() public {
        vm.startPrank(governance);
        address testFacet = address(new TestFacet());

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = bytes4(keccak256('t2()'));

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: testFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        IDiamondCut(governance).diamondCut(cut, address(0), '');
        (bool success, ) = governance.call(abi.encodeWithSignature('t2()'));
        require(success);

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: functionSelectors
        });
        IDiamondCut(governance).diamondCut(cut, address(0), '');

        vm.expectRevert();
        (success, ) = governance.call(abi.encodeWithSignature('t2()'));
        require(success);
        vm.stopPrank();
    }

    function test_RevertWhen_TransferOnEmergencyStop() public {
        vm.startPrank(governance);
        TestToken(token_).mint(player, 11);
        vm.stopPrank();

        vm.startPrank(player);
        address[] memory targets = new address[](1);
        targets[0] = token_;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = bytes4(keccak256('enableStop()'));

        bytes[] memory data = new bytes[](1);
        data[0] = '';

        uint256 id = GovernanceFacet(governance).propose(5 minutes, targets, values, signatures, data, 'test');

        GovernanceFacet(governance).execute(id);

        vm.warp(block.timestamp + 6 minutes);
        GovernanceFacet(governance).execute(id);

        vm.expectRevert();
        TestToken(token_).transfer(address(this), 1);
        vm.stopPrank();
    }

    function test_TokenDepositVotes() public {
        vm.startPrank(governance);
        TestToken(token_).mint(player, 11);
        TestToken(token_).mint(voter, 11);
        vm.stopPrank();

        vm.startPrank(player);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = bytes4(keccak256('t1()'));

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: token_,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        address[] memory targets = new address[](1);
        targets[0] = governance;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = IDiamondCut.diamondCut.selector;

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(cut, address(0), '');

        uint256 id = GovernanceFacet(governance).propose(5 minutes, targets, values, signatures, data, 'test');
        vm.stopPrank();

        vm.startPrank(voter);
        GovernanceFacet(governance).depositVotes(id, false, TestToken(token_).balanceOf(voter));

        vm.warp(block.timestamp + 6 minutes);
        GovernanceFacet(governance).execute(id);

        vm.stopPrank();

        vm.expectRevert();
        (bool success, ) = governance.call(abi.encodeWithSignature('t1()'));
        require(success);

        console.log(TestToken(token_).balanceOf(governance));
    }

    function test_WithdrawVotes() public {
        vm.startPrank(governance);
        TestToken(token_).mint(player, 11);
        TestToken(token_).mint(voter, 11);
        vm.stopPrank();

        vm.startPrank(player);
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = bytes4(keccak256('t1()'));

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: token_,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        address[] memory targets = new address[](1);
        targets[0] = governance;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = IDiamondCut.diamondCut.selector;

        bytes[] memory data = new bytes[](1);
        data[0] = abi.encode(cut, address(0), '');

        uint256 id = GovernanceFacet(governance).propose(5 minutes, targets, values, signatures, data, 'test');
        vm.stopPrank();

        vm.startPrank(voter);
        GovernanceFacet(governance).depositVotes(id, false, TestToken(token_).balanceOf(voter));

        vm.expectRevert();
        GovernanceFacet(governance).withdrawVotes(id);

        vm.warp(block.timestamp + 6 minutes);
        GovernanceFacet(governance).execute(id);

        GovernanceFacet(governance).withdrawVotes(id);
        GovernanceFacet(governance).withdrawVotes(id);
        GovernanceFacet(governance).withdrawVotes(id);
        vm.stopPrank();

        console.log(TestToken(token_).balanceOf(governance));
        console.log(TestToken(token_).balanceOf(voter));
    }
}

contract TestToken is ERC20 {
    address public owner_;
    bool public stop;

    constructor(address owner) ERC20("Test Token", "TOKEN") {
        owner_ = owner;
        _mint(msg.sender, 1000000);
    }

    modifier isOwner() {
        require(msg.sender == owner_, 'You are not the owner.');
        _;
    }

    modifier isStop() {
        require(!stop, 'Emergency Stop.');
        _;
    }

    function setOwner(address owner) public isOwner() isStop() {
        owner_ = owner;
    }

    function enableStop() public isOwner() {
        stop = true;
    }

    function disableStop() public isOwner() {
        stop = false;
    }

    function mint(address to, uint256 value) public isOwner() isStop() {
        _mint(to, value);
    }

    function transfer(address recipient, uint256 amount) 
        public override isStop() returns (bool) 
    {
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) 
        public override isStop() returns (bool) 
    {
        if(msg.sender == owner_) {
            _transfer(sender, recipient, amount);
            return true;
        }
        return super.transferFrom(sender, recipient, amount);
    }

    function t1() public view isOwner() {
        console.log('t1');
        console.log('msg.sender: ', msg.sender);
    }
}

contract TestFacet {
    function setWorker(address worker) public {
        LibDiamond.localStorage().worker = worker;
    }

    function t2() public pure {
        console.log('t2');
    }
}