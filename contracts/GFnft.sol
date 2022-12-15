// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/token/ERC721/ERC721.sol";
import "OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/utils/Counters.sol";
import "OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/access/Ownable.sol";


//-------------------------------------------------
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/538b6d21b15733601f9193af5b9f662b94f16ea1/contracts/token/ERC721/ERC721.sol
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

//-------------------------------------------------
contract GFnft is ERC721, Ownable {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string[] test_lst;
    
    //-------------------------------------------------
    constructor(string memory pSymbolStr) ERC721("GFnft", pSymbolStr) {
    
    }

    //-------------------------------------------------
    function mintNft(address pReceiverAddr, string memory tokenURI) external onlyOwner returns (uint256) {
        _tokenIds.increment();

        uint256 newNftTokenId = _tokenIds.current();
        _mint(pReceiverAddr, newNftTokenId);
        // _setTokenURI(newNftTokenId, tokenURI);

        return newNftTokenId;
    }

    //-------------------------------------------------
    // CONTRACT_URI - OpenSea specific
    //                storefront-level metadata for your contract.
    // metadata format:
    // {
    //     "name": "OpenSea Creatures",
    //     "description": "OpenSea Creatures are adorable aquatic beings primarily for demonstrating what can be done using the OpenSea platform. Adopt one today to try out all the OpenSea buying, selling, and bidding feature set.",
    //     "image": "https://openseacreatures.io/image.png",
    //     "external_link": "https://openseacreatures.io",
    //     "seller_fee_basis_points": 100, # Indicates a 1% seller fee.
    //     "fee_recipient": "0xA97F337c39cccE66adfeCB2BF99C1DdC54C2D721" # Where seller fees will be paid to.
    // }

    function contractURI() public view returns (string memory) {
        return "https://metadata-url.com/my-metadata";
    }

    //-------------------------------------------------
    function tester_modifier(string calldata p_s) public {
        test_lst.push(p_s);
    }
    function tester_arr() public view returns(string[] memory) {
        return test_lst;
    }
    function tester() public view returns(uint) {
        return 4;
    }
}