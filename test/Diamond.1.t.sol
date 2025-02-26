// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import 'forge-std/Test.sol';

import '../contracts/helpers/Deploy.sol';
import '../contracts/interfaces/IDiamondLoupe.sol';
import '../contracts/facets/execution/GovernanceFacet.sol';

contract PublicTest1 is Test {
    address player = makeAddr('player');


    address public governance;

    constructor() {
        // vm.startPrank(player);
        governance = Deploy.deploy();

        address governaceFacet = address(new GovernanceFacet());

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = 0x12345678;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: governaceFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        IDiamondCut(governance).diamondCut(cut, address(0), '');
        // vm.stopPrank();
    }

    function test() public {
        console.log('facet length: ');
        console.log(IDiamondLoupe(governance).facets().length);
    }
}