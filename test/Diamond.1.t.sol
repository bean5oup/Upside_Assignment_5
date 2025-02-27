// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import 'forge-std/Test.sol';

import '../contracts/interfaces/IDiamondLoupe.sol';
import '../contracts/facets/GovernanceFacet.sol';
import '../contracts/Base.sol';

contract PublicTest1 is Test {
    address player = makeAddr('player');

    address public governance;

    constructor() {
        governance = address(new Base());
    }

    function test_RevertWhen_DirectAccess() public {
        address testFacet = address(new GovernanceFacet());

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
        address token = address(new TestToken(governance));

        address[] memory targets = new address[](1);
        targets[0] = token;

        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        bytes4[] memory signatures = new bytes4[](1);
        signatures[0] = bytes4(keccak256('mint()'));

        bytes[] memory data = new bytes[](1);
        data[0] = '';

        uint256 id = GovernanceFacet(governance).propose(5 minutes, targets, values, signatures, data, 'test');

        GovernanceFacet(governance).execute(id);

        vm.warp(block.timestamp + 5 minutes);
        GovernanceFacet(governance).execute(id);
    }

    function test_RevertWhen_AddTokenFacet8CallMint() public {
        console.log('this: ', address(this));
        // Add the token contract as a facet so that its mint() can be used arbitrarily.
        address token = address(new TestToken(governance));

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = bytes4(keccak256('mint()'));

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: token,
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
        (bool success, ) = governance.call(abi.encodeWithSignature('mint()'));
        vm.expectRevert();
        require(success);
    }

    function test_SetWorker() public {

    }
}

contract TestToken is ERC20 {
    address owner_;

    constructor(address owner) ERC20("Test Token", "TOKEN") {
        owner_ = owner;
        _mint(msg.sender, 1000000);
    }

    function mint() public {
        console.log(msg.sender);
        require(msg.sender == owner_, 'You are not a owner.');
        console.log('mint', msg.sender);
    }
}