// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter private currentTokenId;

    /// @dev Base token URI used as a prefix by tokenURI().
    string public baseTokenURI;

    constructor() ERC721("FLOW-DANTE", "FLOW-DANTE") {
        baseTokenURI = "";
    }

    function mintTo(address recipient) public returns (uint256) {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    /**
        @dev Returns the total tokens minted so far.
        1 is always subtracted from the Counter since it tracks the next available tokenId.
     */
    function totalSupply() public view returns (uint256) {
        return currentTokenId.current() - 1;
    }

    /// @dev Returns an URI for a given token ID
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return "https://raw.githubusercontent.com/wuyahuang/opensea/main/1";
    }
}
