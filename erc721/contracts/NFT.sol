// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721 {
    mapping(uint256 => string) tokens;
    mapping(uint256 => address) receivers;
    mapping(uint256 => string) hashValues;

    constructor() ERC721("FLOW-DANTE", "FLOW-DANTE") {
    }

    function crossChainPending(uint256 tokenId, address receiver, string memory token_url, string memory hashValue) public returns (bool){
        // if token is already exists
        assert(keccak256(abi.encodePacked(tokens[tokenId])) != keccak256(abi.encodePacked("")));

        tokens[tokenId] = token_url;
        receivers[tokenId] = receiver;
        hashValues[tokenId] = hashValue;
        return true;
    }

    function crossChainClaim(uint256 tokenId, string memory anwser) public returns (bool){
        assert(msg.sender == receivers[tokenId]);
        
        // compare hashed value
        bytes32 anwserHashValue = sha256(abi.encodePacked(anwser));
        assert(keccak256(abi.encodePacked(bytes32ToString(anwserHashValue))) == keccak256(abi.encodePacked(hashValues[tokenId])));
        
        delete receivers[tokenId];
        delete hashValues[tokenId];
        
        return true;
    }

    /// @dev Returns an URI for a given token ID
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return tokens[tokenId];
    }

    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}
