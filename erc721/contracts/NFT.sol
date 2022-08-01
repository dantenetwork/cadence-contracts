// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721 {
    mapping(uint256 => string) tokens;
    mapping(uint256 => address) receivers;
    mapping(uint256 => bytes32) hashValues;

    // Cross chain transfer NFT to other blockchain network
    string[][] public crossChainPending;

    constructor() ERC721("FLOW-DANTE", "FLOW-DANTE") {
    }

    event show(bytes32 hash);
    event showString(string hash);

    /// @dev Mint NFT from other blockchains
    function crossChainMint(uint256 tokenId, address receiver, string memory tokenURL, bytes32 hashValue) public returns (bool){
        assert(tokenId > 0);
        // ensure token is not exists
        assert(_exists(tokenId) == false);
        assert(receivers[tokenId] == address(0));

        tokens[tokenId] = tokenURL;
        receivers[tokenId] = receiver;
        hashValues[tokenId] = hashValue;

        return true;
    }

    /// @dev Query hash value by tokenId
    function getHashValue(uint256 tokenId) public view virtual returns (bytes32 hashValue){
        return hashValues[tokenId];
    }

    /// @dev Receiver submit random number to claim NFT which was minted by other blockchains
    function crossChainClaim(uint256 tokenId, string memory anwser) public returns (bool){
        // Ensure token receiver equals to message sender
        assert(receivers[tokenId] == msg.sender);
                
        // Compare hashed value
        bytes32 anwserHashValue = sha256(abi.encodePacked(anwser));
        assert(anwserHashValue == hashValues[tokenId]);
        
        _safeMint(receivers[tokenId], tokenId);

        delete receivers[tokenId];
        delete hashValues[tokenId];
        
        return true;
    }

    /// @dev Lock NFT to contract owner, and push cross chain info into crossChainPending
    function crossChainTransfer(uint256 tokenId, string memory receiver, string memory hashValue) public returns (bool){
        // Ensure token is exists
        assert(_exists(tokenId) == true);
 
        // crossChainPending[tokenId] = [receiver, tokens[tokenId], hashValue];
        crossChainPending.push([Strings.toString(tokenId), receiver, tokens[tokenId], hashValue]);

        _transfer(msg.sender, address(0x71Fa7558e22Ba5265a1e9069dcd2be7c6735BE23 ), tokenId);

        return true;
    }

    /// @dev Returns cross chain transfer info for a given token ID
    function queryCrossChainPending() public view virtual returns (string[][] memory){
        return crossChainPending;
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

     /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }

    function clearMsg() public {
        delete crossChainPending;
        // crossChainPending = new string [][](0);
    }
}
