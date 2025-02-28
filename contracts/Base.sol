// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {LibDiamond} from './utils/LibDiamond.sol';
import {IDiamondCut} from './interfaces/IDiamondCut.sol';
import './facets/DiamondCutFacet.sol';
import './facets/DiamondLoupeFacet.sol';
import './facets/GovernanceFacet.sol';

contract Base {
    constructor(address token) {
        LibDiamond.setWorker(address(this));
        LibDiamond.localStorage().token = token;

        address diamondCutFacet = address(new DiamondCutFacet());

        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](3);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: diamondCutFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });

        // Add Diamond Loupe Facet
        address loupe = address(new DiamondLoupeFacet());
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;

        cut[1] = IDiamondCut.FacetCut({
            facetAddress: loupe,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        // Add Governance Facet
        address governanceFacet = address(new GovernanceFacet());
        bytes4[] memory governanceSelectors = new bytes4[](6);
        governanceSelectors[0] = IGovernance.propose.selector;
        governanceSelectors[1] = IGovernance.execute.selector;
        governanceSelectors[2] = IGovernance.status.selector;
        governanceSelectors[3] = IGovernance.depositVotes.selector;
        governanceSelectors[4] = IGovernance.withdrawVotes.selector;
        governanceSelectors[5] = IGovernance.executeProposal.selector;

        cut[2] = IDiamondCut.FacetCut({
            facetAddress: governanceFacet,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: governanceSelectors
        });

        // console.logBytes(abi.encode(cut));
        // diamondCut.diamondCut(cut, address(0), '');

        LibDiamond.diamondCut(cut, address(0), '');
    }

    fallback() external payable {
        // get facet from function selector
        address facet = LibDiamond.localStorage().selectorToFacetAndPosition[msg.sig].facetAddress;
        require(facet != address(0), "Diamond: Function does not exist");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
}