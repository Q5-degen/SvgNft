//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {SvgNft} from "../src/SvgNft.sol";

contract DeploySvgNft is Script {
    function run() external returns (HelperConfig _config, SvgNft _st) {
        _config = new HelperConfig();

        vm.startBroadcast();
        _st = new SvgNft(
            _config.getParams().name,
            _config.getParams().symbol,
            _config.getParams().baseURI,
            _config.getParams().happyTokenURI,
            _config.getParams().sadTokenURI,
            _config.getParams().mintPrice
        );
        vm.stopBroadcast();
    }
}
