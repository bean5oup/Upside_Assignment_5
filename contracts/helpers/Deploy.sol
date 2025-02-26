// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import '../facets/DiamondCutFacet.sol';
import '../facets/DiamondLoupeFacet.sol';
import '../Governance.sol';

library Deploy {
    function deploy() public returns (address governance) {
        address diamondCutFacet = address(new DiamondCutFacet());
        governance = address(new Governance(address(this), diamondCutFacet));

        address loupe = address(new DiamondLoupeFacet());
        IDiamondCut diamondCut = IDiamondCut(governance);

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);

        // Add Diamond Loupe Facet
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

        cut[0] = IDiamondCut.FacetCut({
            facetAddress: loupe,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        // Add Governance Facet

        diamondCut.diamondCut(cut, address(0), '');
    }
}