//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    Params private s_params;

    string private constant APP_BASE_URI = "data:application/json;base64,"; // prefixe for the whole metadata
    string private constant IMAGE_BASE_URI = "data:image/svg+xml;base64,"; // prefixe for the image
    string private constant NAME = "SVG NFT";
    string private constant SYMBOL = "ST";
    string private constant HAPPY_IMAGE_METADATA_NAME = "Happy Chad";
    string private constant SAD_IMAGE_METADATA_NAME = "Sad Cub";
    uint256 private constant MINT_PRICE = 1e15;

    bytes private s_happyImg =
        abi.encodePacked(vm.readFile("./img/second.svg"));
    bytes private s_sadImg = abi.encodePacked(vm.readFile("./img/first.svg"));

    string private s_base64EncodedHappyImg =
        string(abi.encodePacked(IMAGE_BASE_URI, base64Encode(s_happyImg)));
    string private s_base64EncodedSadImg =
        string(abi.encodePacked(IMAGE_BASE_URI, base64Encode(s_sadImg)));

    bytes private s_happyTokenUri =
        abi.encodePacked(
            '{"name":"',
            HAPPY_IMAGE_METADATA_NAME,
            '", "description":"A minimalist SVG artwork depicting a stick figure rendered in white. The figure features a circular head, a central line for the body, and angled lines for arms and legs, creating a simple yet expressive character.", ',
            '"attributes": [',
            '{"trait_type": "Background", "value": "None"},',
            '{"trait_type": "Figure Color", "value": "White"},',
            '{"trait_type": "Head Shape", "value": "Circle"},',
            '{"trait_type": "Body Structure", "value": "Line"},',
            '{"trait_type": "Arm Style", "value": "Raised Diagonal"},',
            '{"trait_type": "Leg Style", "value": "Spread Diagonal"},',
            '{"trait_type": "Overall Style", "value": "Stylized Stick Figure"}',
            '], "image":"',
            s_base64EncodedHappyImg,
            '"}'
        );

    bytes private s_sadTokenUri =
        abi.encodePacked(
            '{"name":"',
            SAD_IMAGE_METADATA_NAME,
            '", "description":"An abstract geometric artwork rendered in SVG, featuring a prominent red circle connected to a series of lines and a curved path, creating a dynamic and minimalist visual.", ',
            '"attributes": [',
            '{"trait_type": "Background", "value": "None"},',
            '{"trait_type": "Primary Color", "value": "Red"},',
            '{"trait_type": "Core Shape", "value": "Circle"},',
            '{"trait_type": "Line Style", "value": "Solid"},',
            '{"trait_type": "Complexity", "value": "Minimalist"},',
            '{"trait_type": "Composition", "value": "Abstract Geometric"}',
            '], "image":"',
            s_base64EncodedSadImg,
            '"}'
        );

    string base64EncodedHappyTokenUri = base64Encode(s_happyTokenUri);
    string base64EncodedSadTokenUri = base64Encode(s_sadTokenUri);

    struct Params {
        string name;
        string symbol;
        string baseURI;
        string happyTokenURI;
        string sadTokenURI;
        uint256 mintPrice;
    }

    constructor() {
        if (block.chainid == 11155111) {
            s_params = whenOnSepolia();
        } else {
            // if other chain then do something else
        }
    }

    function base64Encode(
        bytes memory _data
    ) private pure returns (string memory _dataEncoded) {
        _dataEncoded = Base64.encode(_data);
    }

    function whenOnSepolia() private view returns (Params memory _params) {
        _params = Params({
            name: NAME,
            symbol: SYMBOL,
            baseURI: APP_BASE_URI,
            happyTokenURI: base64EncodedHappyTokenUri,
            sadTokenURI: base64EncodedSadTokenUri,
            mintPrice: MINT_PRICE
        });
    }

    function getParams() external view returns (Params memory _params) {
        _params = s_params;
    }
}
