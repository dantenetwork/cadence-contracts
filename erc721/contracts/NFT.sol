// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 {
    mapping(uint256 => string) tokens;
    mapping(uint256 => address) receivers;
    mapping(uint256 => bytes32) hashValues;

    constructor() ERC721("FLOW-DANTE", "FLOW-DANTE") {
    }

    event show(bytes32 hash);
    event showString(string hash);

    function crossChainMint(uint256 tokenId, address receiver, string memory token_url, bytes32 hashValue) public returns (bool){
        assert(tokenId > 0);
        // ensure token is not exists
        assert(_exists(tokenId) == false);
        assert(receivers[tokenId] == address(0));

        tokens[tokenId] = token_url;
        receivers[tokenId] = receiver;
        hashValues[tokenId] = hashValue;

        return true;
    }

    function getHashValue(uint256 tokenId) public view virtual returns (bytes32 hashValue){
        return hashValues[tokenId];
    }

    function crossChainClaim(uint256 tokenId, string memory anwser) public returns (bool){
        // ensure token is exists
        assert(receivers[tokenId] != address(0));
                
        // compare hashed value
        bytes32 anwserHashValue = sha256(abi.encodePacked(anwser));
        assert(anwserHashValue == hashValues[tokenId]);
        
        _safeMint(receivers[tokenId], tokenId);

        delete receivers[tokenId];
        delete hashValues[tokenId];
        
        return true;
    }

    /// @dev Returns an URI for a given token ID
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return tokens[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function exists(uint256 tokenId) public view virtual returns (bool) {
        return _exists(tokenId);
    }
}
