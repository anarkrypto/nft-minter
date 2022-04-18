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
        string metadataURI;
        uint256 createdTime;
    }

    mapping(uint256 => NFT) private dataNFT;

    constructor() ERC1155("") {
        owner = msg.sender;
    }

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

    function mint(
        address to,
        uint256 amount,
        string memory metadata
    ) external _ownerOnly {
        _tokenIds.increment();
        uint256 newId = _tokenIds.current();
        _mint(to, newId, amount, "");
        dataNFT[newId] = NFT({
            metadataURI: string(
                abi.encodePacked("ipfs://", metadata, "/metadata.json")
            ),
            createdTime: block.timestamp
        });
    }

    function nftInfo(uint256 id) external view returns (NFT memory) {
        return dataNFT[id];
    }

    function nftMetadataURI(uint256 id) external view returns (string memory) {
        return dataNFT[id].metadataURI;
    }
}
