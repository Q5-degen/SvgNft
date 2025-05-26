// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {SvgNft} from "../../src/SvgNft.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeploySvgNft} from "../../script/DeploySvgNft.s.sol";
import {Log} from "@chainlink/automation/interfaces/ILogAutomation.sol";
import {Burn, Mint, TokenURI} from "../../script/Interactions.s.sol";

contract SvgNftTest is Test {
    HelperConfig private s_config;
    DeploySvgNft private s_deployer;
    SvgNft private s_st;
    Burn private s_burn;
    Mint private s_mint;
    TokenURI private s_checkUri;
    address private s_stAddr;

    constructor() {}

    function setUp() external {
        s_deployer = new DeploySvgNft();
        s_burn = new Burn();
        s_mint = new Mint();
        s_checkUri = new TokenURI();
        (s_config, s_st) = s_deployer.run();
        s_stAddr = address(s_st);
    }

    function testMintPlusCheckURI() external {
        uint256 requiredMintAmount = s_config.getParams().mintPrice;
        uint256 tokenIdTobeMinted = s_st.tokenIdMinted();

        s_mint.mint(s_stAddr, requiredMintAmount);

        string memory expectedUri = string(
            abi.encodePacked(
                s_config.getParams().baseURI,
                s_config.getParams().happyTokenURI
            )
        );
        string memory uri = s_checkUri.check(s_stAddr, tokenIdTobeMinted);

        assert(
            keccak256(abi.encodePacked(uri)) ==
                keccak256(abi.encodePacked(expectedUri))
        );
    }

    function testMintPlusBurn() external {
        uint256 requiredMintAmount = s_config.getParams().mintPrice;
        uint256 tokenIdTobeMinted = s_st.tokenIdMinted();

        s_mint.mint(s_stAddr, requiredMintAmount);

        s_burn.burn(s_stAddr, tokenIdTobeMinted);

        vm.expectRevert();
        s_st.tokenIdStatus(tokenIdTobeMinted);
    }
}
