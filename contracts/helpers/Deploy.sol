// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import 'forge-std/Test.sol';

import '../facets/DiamondCutFacet.sol';
import '../facets/DiamondLoupeFacet.sol';
import '../facets/GovernanceFacet.sol';
import '../Base.sol';

library Deploy {
// contract Deploy is Test {
    function deploy() public returns (address governance) {
        // address diamondCutFacet = address(new DiamondCutFacet());
        // governance = address(new Base(address(this), diamondCutFacet));

        // IDiamondCut diamondCut = IDiamondCut(governance);

        // IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](2);

        // // Add Diamond Loupe Facet
        // address loupe = address(new DiamondLoupeFacet());
        // bytes4[] memory loupeSelectors = new bytes4[](4);
        // loupeSelectors[0] = IDiamondLoupe.facets.selector;
        // loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        // loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        // loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

        // cut[0] = IDiamondCut.FacetCut({
        //     facetAddress: loupe,
        //     action: IDiamondCut.FacetCutAction.Add,
        //     functionSelectors: loupeSelectors
        // });

        // // Add Governance Facet
        // address governanceFacet = address(new GovernanceFacet());
        // bytes4[] memory governanceSelectors = new bytes4[](6);
        // governanceSelectors[0] = IGovernance.propose.selector;
        // governanceSelectors[1] = IGovernance.execute.selector;
        // governanceSelectors[2] = IGovernance.status.selector;
        // governanceSelectors[3] = IGovernance.vote.selector;
        // governanceSelectors[4] = IGovernance.addProposal.selector;
        // governanceSelectors[5] = IGovernance.executeProposal.selector;

        // cut[1] = IDiamondCut.FacetCut({
        //     facetAddress: governanceFacet,
        //     action: IDiamondCut.FacetCutAction.Add,
        //     functionSelectors: governanceSelectors
        // });

        // console.logBytes(abi.encode(cut));
        // diamondCut.diamondCut(cut, address(0), '');
        // console.log('gg');
    }
}