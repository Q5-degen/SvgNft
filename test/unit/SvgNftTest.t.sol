// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {SvgNft} from "../../src/SvgNft.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DeploySvgNft} from "../../script/DeploySvgNft.s.sol";
import {Log} from "@chainlink/automation/interfaces/ILogAutomation.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract SvgNftTest is IERC721Receiver, Test {
    HelperConfig private s_config;
    DeploySvgNft private s_deployer;
    SvgNft private s_st;
    address private s_stAddr;

    address private constant DEFAULT_BROADCASTER =
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    uint256 private constant FUND = 1 ether;

    address private s_randomMinter = makeAddr("minter");

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event NftBurner(address indexed _owner);

    function setUp() external {
        s_deployer = new DeploySvgNft();
        (s_config, s_st) = s_deployer.run();
        s_stAddr = address(s_st);
        vm.deal(s_randomMinter, FUND);
    }

    function testMintFailedWithSvgNft__MintPriceNotReached() external {
        vm.prank(s_randomMinter);
        vm.expectRevert(SvgNft.SvgNft__MintPriceNotReached.selector);
        s_st.mint{value: FUND}();
    }

    function testMintFailedWithSvgNft__OnlyOneMintPerWallet() external {
        uint256 loop = 2;
        uint256 mintPrice = s_config.getParams().mintPrice;

        for (uint256 index; index < loop; index++) {
            if (index != 0) {
                vm.prank(s_randomMinter);
                vm.expectRevert(SvgNft.SvgNft__OnlyOneMintPerWallet.selector);
                s_st.mint{value: mintPrice}();
            } else {
                vm.prank(s_randomMinter);
                s_st.mint{value: mintPrice}();
            }
        }
    }

    function testMintSucceed() external {
        uint256 mintPrice = s_config.getParams().mintPrice;

        uint256 tokenIdMinted = s_st.tokenIdMinted();

        vm.prank(s_randomMinter);
        s_st.mint{value: mintPrice}();

        address owner = s_st.ownerOf(tokenIdMinted);
        assert(owner == s_randomMinter);

        SvgNft.IdStatus expectedStatus = SvgNft.IdStatus.REGULAR;
        SvgNft.IdStatus retrievedIdStatus = s_st.tokenIdStatus(tokenIdMinted);
        assert(expectedStatus == retrievedIdStatus);
        assert(tokenIdMinted == 0);
    }

    function testBurnFailedWithTokenIdNotMintedYet() external {
        uint256 randomTokenId = 1000;

        vm.prank(s_randomMinter);
        vm.expectRevert();
        s_st.burn(randomTokenId);
    }

    function testBurnFailedWithSvgNft__NotAllowedToBurnTokenId() external {
        uint256 mintPrice = s_config.getParams().mintPrice;

        uint256 tokenIdMinted = s_st.tokenIdMinted();

        vm.prank(s_randomMinter);
        s_st.mint{value: mintPrice}();

        vm.expectRevert(SvgNft.SvgNft__NotAllowedToBurnTokenId.selector);
        s_st.burn(tokenIdMinted);
    }

    function testBurnSucceedWithTransferEvent() external {
        uint256 mintPrice = s_config.getParams().mintPrice;

        uint256 tokenIdMinted = s_st.tokenIdMinted();

        vm.prank(s_randomMinter);
        s_st.mint{value: mintPrice}();
        uint256 randomMinterBal = s_st.balanceOf(s_randomMinter);

        vm.prank(s_randomMinter);
        vm.expectEmit(true, true, true, false, s_stAddr);
        emit Transfer(s_randomMinter, address(0), tokenIdMinted);
        s_st.burn(tokenIdMinted);

        vm.expectRevert();
        s_st.getApproved(tokenIdMinted);

        uint256 randomMinterCurrentBal = s_st.balanceOf(s_randomMinter);
        assert(randomMinterCurrentBal == (randomMinterBal - 1));

        vm.expectRevert();
        s_st.ownerOf(tokenIdMinted);

        vm.expectRevert();
        s_st.tokenIdStatus(tokenIdMinted);
    }

    function testBurnSucceedWithNftBurnerEvent() external {
        uint256 mintPrice = s_config.getParams().mintPrice;

        uint256 tokenIdMinted = s_st.tokenIdMinted();

        vm.prank(s_randomMinter);
        s_st.mint{value: mintPrice}();

        vm.prank(s_randomMinter);
        vm.expectEmit(true, false, false, false, s_stAddr);
        emit NftBurner(s_randomMinter);
        s_st.burn(tokenIdMinted);
    }

    function testTokenURIFailedWithRequireMinted() external {
        uint256 randomTokenId = 2000;

        vm.expectRevert();
        s_st.tokenURI(randomTokenId);
    }

    function testTokenURISucceedWithHappyTokenUri() external {
        uint256 mintPrice = s_config.getParams().mintPrice;

        uint256 tokenIdMinted = s_st.tokenIdMinted();

        vm.prank(s_randomMinter);
        s_st.mint{value: mintPrice}();

        vm.prank(s_randomMinter);
        string memory tokenUri = s_st.tokenURI(tokenIdMinted);

        string memory expectedTokenUriWithoutPrefixe = s_config
            .getParams()
            .happyTokenURI;
        string memory appBaseUri = s_config.getParams().baseURI;

        assert(
            keccak256(
                abi.encodePacked(appBaseUri, expectedTokenUriWithoutPrefixe)
            ) == keccak256(abi.encodePacked(tokenUri))
        );
    }

    function testTokenURISucceedWithSadTokenUri() external {
        uint256 mintPrice = s_config.getParams().mintPrice;

        uint256 tokenIdMinted = s_st.tokenIdMinted();

        vm.prank(s_randomMinter);
        s_st.mint{value: mintPrice}();

        vm.prank(s_randomMinter);
        s_st.burn(tokenIdMinted);

        bytes32 castedRandomMinter = bytes32(uint256(uint160(s_randomMinter)));

        Log memory log;
        log.topics = new bytes32[](2);
        log.topics[0] = bytes32(0);
        log.topics[1] = castedRandomMinter;

        (bool upkeepNeeded, bytes memory performData) = s_st.checkLog(log, "");
        assertTrue(upkeepNeeded);

        address passedAddress = abi.decode(performData, (address));
        assert(passedAddress == s_randomMinter);

        uint256 newTokenIdtoBeMinted = s_st.tokenIdMinted();

        s_st.performUpkeep(performData);

        address owner = s_st.ownerOf(newTokenIdtoBeMinted);
        assert(owner == s_randomMinter);

        string memory tokenUri = s_st.tokenURI(newTokenIdtoBeMinted);

        string memory expectedTokenUriWithoutPrefixe = s_config
            .getParams()
            .sadTokenURI;

        string memory appBaseUri = s_config.getParams().baseURI;
        assert(
            keccak256(
                abi.encodePacked(appBaseUri, expectedTokenUriWithoutPrefixe)
            ) == keccak256(abi.encodePacked(tokenUri))
        );
    }

    function testNameAndSymbolAndDevWallet() external view {
        string memory name = s_st.name();
        string memory symbol = s_st.symbol();
        address dev = s_st.devWallet();

        string memory expectedName = s_config.getParams().name;
        string memory expectedSymbol = s_config.getParams().symbol;

        assert(
            keccak256(abi.encodePacked(expectedName)) ==
                keccak256(abi.encodePacked(name))
        );
        assert(
            keccak256(abi.encodePacked(expectedSymbol)) ==
                keccak256(abi.encodePacked(symbol))
        );
        assert(dev == DEFAULT_BROADCASTER);
    }

    function testLowLevelCallForReceiveFunc() external {
        bytes memory emptyBytes = new bytes(0);

        uint256 tokenIdToBeMinted = 0;
        uint256 requiredMintMount = s_config.getParams().mintPrice;

        (bool success, ) = payable(s_stAddr).call{value: requiredMintMount}(
            emptyBytes
        );

        assertTrue(success);

        SvgNft.IdStatus status = s_st.tokenIdStatus(tokenIdToBeMinted);
        assert(status == SvgNft.IdStatus.REGULAR);
    }

    function testLowLevelCallForFullbackFunc() external {
        bytes memory notEmptyBytes = " ";

        uint256 tokenIdToBeMinted = 0;
        uint256 requiredMintMount = s_config.getParams().mintPrice;

        vm.prank(s_randomMinter);
        (bool success, ) = payable(s_stAddr).call{value: requiredMintMount}(
            notEmptyBytes
        );

        assertTrue(success);

        address owner = s_st.ownerOf(tokenIdToBeMinted);
        assert(owner == s_randomMinter);
    }

    function testLowLevelCallToBurnMintedTokenId() external {
        uint256 tokenIdToBeMinted = 0;
        uint256 requiredMintAmount = s_config.getParams().mintPrice;

        vm.prank(s_randomMinter);
        s_st.mint{value: requiredMintAmount}();

        vm.prank(s_randomMinter);
        (bool success, bytes memory returnData) = s_stAddr.call(
            abi.encodeWithSignature("burn(uint256)", tokenIdToBeMinted)
        );

        assertTrue(success);
        assert(returnData.length == 0);

        vm.expectRevert();
        s_st.tokenIdStatus(tokenIdToBeMinted);
    }

    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external pure override returns (bytes4 retval) {
        retval = this.onERC721Received.selector;
    }
}
