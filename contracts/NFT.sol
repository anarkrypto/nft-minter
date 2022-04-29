// contracts/NFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MintNFT is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public owner;

    modifier _ownerOnly() {
        require(msg.sender == owner, "Restricted to owner!");
        _;
    }

    struct NFT {
        string uri;
        uint256 createdTime;
    }

    mapping(uint256 => NFT) private dataNFT;

    constructor() ERC1155("") {
        owner = msg.sender;
    }

    /**
     * Simplifies single token transfer removing `from` and `data`.
     */
    function transfer(
        address to,
        uint256 id,
        uint256 amount
    ) external {
        safeTransferFrom({
            from: msg.sender,
            to: to,
            id: id,
            amount: amount,
            data: "0x"
        });
    }

    /**
     * Simplifies token batch transfer.
     */
    function batchTransfer(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external {
        safeBatchTransferFrom({
            from: msg.sender,
            to: to,
            ids: ids,
            amounts: amounts,
            data: "0x"
        });
    }

    /**
     * Gives the contract owner the right to create new `amount` of tokens and assigns them to `to`.
     * The token id starts at 1 and automatically increases as new creations are made
     *
     * Requirements:
     *
     * - `cid` is a content identifier / cryptographic hash used to point to material in IPFS.
     * - For each file that you uploaded, prepare an IPFS URI of the form ipfs://<CID>/metadata.json.
     * - Read more about it at: https://nft.storage/docs/how-to/mint-erc-1155/
     */
    function mint(
        address to,
        uint256 amount,
        string memory cid
    ) external _ownerOnly {
        _tokenIds.increment();
        uint256 newId = _tokenIds.current();
        _mint(to, newId, amount, "");
        dataNFT[newId] = NFT({
            uri: string(abi.encodePacked("ipfs://", cid, "/metadata.json")),
            createdTime: block.timestamp
        });
    }

    /**

     * Gives the contract owner the right to create multiple `amounts` of different tokens and assigns them to `to`.

     * Requirements:
        - `amounts` and `cids` must be numerical lists of the same lenght 
    */
    function mintBatch(
        address to,
        uint256[] memory amounts,
        string[] memory cids
    ) external _ownerOnly {
        require(
            amounts.length == cids.length,
            "amounts and cids length mismatch"
        );

        uint256[] memory ids = new uint256[](amounts.length);

        for (uint256 i = 0; i < amounts.length; i++) {
            _tokenIds.increment();
            uint256 newId = _tokenIds.current();
            ids[i] += newId;
        }

        _mintBatch(to, ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            dataNFT[ids[i]] = NFT({
                uri: string(
                    abi.encodePacked("ipfs://", cids[i], "/metadata.json")
                ),
                createdTime: block.timestamp
            });
        }
    }

    function tokenInfo(uint256 id) external view returns (NFT memory) {
        return dataNFT[id];
    }

    // ERC-1155 standard method for retrieving the URI associated with a token
    function uri(uint256 id) public view override returns (string memory) {
        return dataNFT[id].uri;
    }

    // ERC-721 standard method for retrieving the URI associated with a token
    function tokenURI(uint256 id) public view returns (string memory) {
        return dataNFT[id].uri;
    }
}
