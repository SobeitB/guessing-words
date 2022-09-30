// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";

contract WordGame is ERC721, ERC721URIStorage, Pausable, Ownable, PullPayment {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Mapping from token ID to word hash
    mapping(uint256 => bytes32) private wordHashes;

    // Mapping from token ID to try value
    mapping(uint256 => uint256) private tryValues;

    // Mapping from token ID to prize value
    mapping(uint256 => uint256) private prizeValues;

    // Creator address
    address private creatorAddress = 0xF02AB5ae5E270118b816fC7185533896F8509787;

    constructor() ERC721("WordGame", "XWG") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(bytes32 wordHash, string memory uri, uint256 tryValue) public payable {

        require(msg.value > 0, "Prize value should be greater then 0");
        require(tryValue > 0, "Try value should be greater then 0");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        wordHashes[tokenId] = wordHash;
        tryValues[tokenId] = tryValue;

        uint256 fee = msg.value * 5 / 100;
        _asyncTransfer(creatorAddress, fee);
        prizeValues[tokenId] = msg.value - fee;
    }

    event guessResult(bool equal, uint256 tokenId);

    function guess(uint256 tokenId, string memory word) public payable returns (bool) {
        require(msg.value == tryValues[tokenId], "Value should be equal to try value");

        bool equal = keccak256(abi.encodePacked(word)) == wordHashes[tokenId];

        uint256 fee = msg.value * 5 / 100;
        _asyncTransfer(creatorAddress, fee);
        _asyncTransfer(ownerOf(tokenId), msg.value - fee);

        if (equal) {
            uint256 prizeFee = prizeValues[tokenId] * 5 / 100;
            _asyncTransfer(creatorAddress, prizeFee);
            _asyncTransfer(msg.sender, prizeValues[tokenId] - prizeFee);
            _burn(tokenId);
        }

        emit guessResult(equal, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    whenNotPaused
    override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}