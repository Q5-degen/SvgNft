//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {SvgNft} from "../src/SvgNft.sol";
import {console} from "forge-std/console.sol";

contract Mint is Script {
    uint256 private constant AMOUNT = 1e15;

    function mint(address _svgAddr, uint256 _amount) public {
        SvgNft svgC = SvgNft(payable(_svgAddr));

        vm.startBroadcast();
        svgC.mint{value: _amount}();
        vm.stopBroadcast();
    }

    function run() external {
        address svgNftAddress = DevOpsTools.get_most_recent_deployment(
            "SvgNft",
            block.chainid
        );
        mint(svgNftAddress, AMOUNT);
    }
}

contract Burn is Script {
    uint256 private constant TOKEN_ID = 0;

    function burn(address _svgAddr, uint256 _tokenId) public {
        SvgNft svgC = SvgNft(payable(_svgAddr));

        vm.startBroadcast();
        svgC.burn(_tokenId);
        vm.stopBroadcast();
    }

    function run() external {
        address svgNftAddress = DevOpsTools.get_most_recent_deployment(
            "SvgNft",
            block.chainid
        );
        burn(svgNftAddress, TOKEN_ID);
    }
}

contract TokenURI is Script {
    uint256 private constant TOKEN_ID = 1;

    function check(
        address _svgAddr,
        uint256 _tokenId
    ) public returns (string memory _uri) {
        SvgNft svgC = SvgNft(payable(_svgAddr));

        vm.startBroadcast();
        _uri = svgC.tokenURI(_tokenId);
        vm.stopBroadcast();

        console.log("TOKEN URI IS : ", _uri);
    }

    function run() external {
        address svgNftAddress = DevOpsTools.get_most_recent_deployment(
            "SvgNft",
            block.chainid
        );
        check(svgNftAddress, TOKEN_ID);
    }
}
