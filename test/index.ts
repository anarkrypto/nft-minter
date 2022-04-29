import { expect } from "chai";
import { ethers } from "hardhat";

let ownerAddress: any
let nftContract: any
const tokenCids = [
  "bafybeibnsoufr2renqzsh347nrx54wcubt5lgkeivez63xvivplfwhtpym",
  "bafyreig6qjssgyu6va4jr3dwly2lnuag5asq4udflohobj4ok6vuwbvw5q",
  "bafyreidq6mmy6vglqlgbxeitgz2qm4zgvbgggtovn5oblwubnlfnrundya"
]

describe("Deploy: construct MintNFT contract", function () {
  it("Should return the new owner address once it's changed", async function () {
    const NFTContract = await ethers.getContractFactory("MintNFT");
    const [owner] = await ethers.getSigners();

    nftContract = await NFTContract.deploy();
    await nftContract.deployed();

    expect(await nftContract.owner()).to.equal(owner.address);

    ownerAddress = owner.address
  });
});

describe("Mint single NFT", function () {
  it("Should create and return NFT uri", async function () {

    // Define NFT data
    const to = ownerAddress
    const amount = 1
    const cid = "bafybeibnsoufr2renqzsh347nrx54wcubt5lgkeivez63xvivplfwhtpym";

    // Mint single NFT
    const receipt = await nftContract.mint(to, amount, cid);

    // Wait for network confirmation
    await receipt.wait();

    // Get token id, first id is always 1 from counter
    const tokenUri = await nftContract.uri(1);

    expect(tokenUri).to.equal(`ipfs://${cid}/metadata.json`);
  });
});

describe("Mint batch NFT", function () {
  it("Should create multiple NFTs", async function () {

    // list items must have matching index
    const tokenAmounts = [1, 20, 1000]

    // Mint nft in batch
    const receipt = await nftContract.mintBatch(ownerAddress, tokenAmounts, tokenCids);
    await receipt.wait();

    const startFrom = 2 // we start id from 2, since we already minted token id `1`

    // Check all URIs
    for (let i = 0; i < tokenCids.length; i++) {
      let tokenId = startFrom + i
      let tokenUri = await nftContract.uri(tokenId);
      expect(tokenUri).to.equal(`ipfs://${tokenCids[i]}/metadata.json`);
    }

  });
});

describe("Burn single NFT", function () {
  it("Should burn a NFT id", async function () {

    const tokenId = 1
    const amount = 1

    // Mint nft in batch
    const receipt = await nftContract.burn(tokenId, amount);
    await receipt.wait();

    // Burnt token should return empty string
    const tokenUri = await nftContract.uri(tokenId);
    expect(tokenUri).to.equal("");

  });
});

describe("Burn batch NFT", function () {
  it("Should burn a batch of NFT ids, checking supply and uri removal", async function () {

    // Uses our previously minted batch tokens
    const tokenIds = [2, 3, 4]
    const supplyAmount = [1, 20, 1000]
    const burnAmount = [1, 10, 999]

    // Mint nft in batch
    const receipt = await nftContract.burnBatch(tokenIds, burnAmount);
    await receipt.wait();

    // Check all URIs and supply
    // If after burning the quantity remains zero, the uri should be removed
    const startFrom = 2
    for (let i = 0; i < tokenIds.length; i++) {
      let tokenId = tokenIds[i]
      let tokenUri = await nftContract.uri(tokenId);
      let calculatedTokenNewSupply = supplyAmount[i] - burnAmount[i]
      let tokenNewSupply = await nftContract.tokenSupply(tokenId)
      expect(tokenNewSupply).to.be.equal(calculatedTokenNewSupply)
      if ( tokenNewSupply == 0) {
        expect(tokenUri).to.equal("");
      } else {
        expect(tokenUri).to.equal(`ipfs://${tokenCids[i]}/metadata.json`);
      }
    }
  });
});