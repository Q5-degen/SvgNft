// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ILogAutomation, Log} from "@chainlink/automation/interfaces/ILogAutomation.sol";

/**
 * @title SvgNft
 * @author selone te
 * @notice This contract mints an NFT with two possible states: "Happy" or "Sad".
 * The state of the NFT changes based on a Chainlink Automation Log Trigger.
 * When a user burns their "Happy" NFT, a new "Sad" NFT is automatically minted to their wallet.
 * This contract demonstrates a basic use case of Chainlink Automation to react to on-chain events.
 */
contract SvgNft is ERC721, ILogAutomation {
    error SvgNft__MintPriceNotReached();
    error SvgNft__OnlyOneMintPerWallet();
    error SvgNft__NotAllowedToBurnTokenId();

    address private immutable i_dev;
    uint256 private immutable i_mintPrice;

    string private s_baseURI;
    string private s_happyTokenURI;
    string private s_sadTokenURI;
    uint256 private s_tokenIdMinted;
    mapping(uint256 => IdStatus) s_tokenIdStatus;

    enum IdStatus {
        REGULAR,
        BURNER
    }

    event NftBurner(address indexed _owner);

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory happyTokenURI_,
        string memory sadTokenURI_,
        uint256 mintPrice_
    ) ERC721(name_, symbol_) {
        i_dev = msg.sender;
        s_baseURI = baseURI_;
        s_happyTokenURI = happyTokenURI_;
        s_sadTokenURI = sadTokenURI_;
        i_mintPrice = mintPrice_;
    }

    receive() external payable {
        mint();
    }

    fallback() external payable {
        mint();
    }

    function mint() public payable {
        if (msg.value != i_mintPrice) revert SvgNft__MintPriceNotReached();
        if (balanceOf(msg.sender) != 0) revert SvgNft__OnlyOneMintPerWallet();

        _safeMint(msg.sender, s_tokenIdMinted);
        s_tokenIdStatus[s_tokenIdMinted] = IdStatus.REGULAR;
        s_tokenIdMinted++;
    }

    function burn(uint256 _tokenId) external {
        bool isApproved = _isApprovedOrOwner(msg.sender, _tokenId);
        if (!isApproved) revert SvgNft__NotAllowedToBurnTokenId();

        address owner = _ownerOf(_tokenId);
        _burn(_tokenId);

        delete s_tokenIdStatus[_tokenId];

        emit NftBurner(owner);
    }

    function performUpkeep(bytes memory performData) external {
        address owner = abi.decode(performData, (address));

        _safeMint(owner, s_tokenIdMinted);
        s_tokenIdStatus[s_tokenIdMinted] = IdStatus.BURNER;
        s_tokenIdMinted++;
    }

    function _baseURI() internal view override returns (string memory) {
        return s_baseURI;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        _requireMinted(_tokenId);

        return
            s_tokenIdStatus[_tokenId] == IdStatus.BURNER
                ? string(abi.encodePacked(_baseURI(), s_sadTokenURI))
                : string(abi.encodePacked(_baseURI(), s_happyTokenURI));
    }

    function checkLog(
        Log memory log,
        bytes memory /*checkData*/
    ) public pure returns (bool upkeepNeeded, bytes memory performData) {
        bytes32[] memory entries = log.topics;
        bytes32 emittedTokenIdOwnerAddress = entries[1];
        address emittedAddress = address(
            uint160(uint256(emittedTokenIdOwnerAddress))
        );
        bytes memory castEmittedAddress = abi.encode(emittedAddress);

        upkeepNeeded = castEmittedAddress.length > 0;
        performData = castEmittedAddress;
    }

    function tokenIdMinted() external view returns (uint256 _id) {
        _id = s_tokenIdMinted;
    }

    function tokenIdStatus(
        uint256 _tokenId
    ) public view returns (IdStatus _status) {
        _requireMinted(_tokenId);

        _status = s_tokenIdStatus[_tokenId];
    }

    function devWallet() external view returns (address _dev) {
        _dev = i_dev;
    }
}
