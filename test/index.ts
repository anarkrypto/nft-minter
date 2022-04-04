import { expect } from "chai";
import { ethers } from "hardhat";

describe("Deploy: construct MintNFT contract", function () {
  it("Should return the new owner address once it's changed", async function () {
    const MintNFT = await ethers.getContractFactory("MintNFT");
    const [owner] = await ethers.getSigners();

    const mintNFT = await MintNFT.deploy();
    await mintNFT.deployed();

    expect(await mintNFT.owner()).to.equal(owner.address);

    describe("Mint NFT", function () {
      it("Should create and return NFT info", async function () {
        const metadataCID =
          "bafybeibnsoufr2renqzsh347nrx54wcubt5lgkeivez63xvivplfwhtpym";

        const newNFTtx = await mintNFT.mint(owner.address, 1, metadataCID);

        await newNFTtx.wait();

        const nftMetadataURI = await mintNFT.nftMetadataURI(1); // First id is always 1

        expect(nftMetadataURI).to.equal(`ipfs://${metadataCID}/metadata.json`);
      });
    });
  });
});
