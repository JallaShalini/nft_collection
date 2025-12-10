const { expect } = require('chai');
const hre = require('hardhat');
const { ethers } = require('hardhat');

describe('NftCollection', function () {
  let nftContract;
  let owner, addr1, addr2, addr3;

  beforeEach(async function () {
    [owner, addr1, addr2, addr3] = await ethers.getSigners();
    const NftCollection = await ethers.getContractFactory('NftCollection');
    nftContract = await NftCollection.deploy();
    await nftContract.waitForDeployment();
  });

  describe('Deployment', function () {
    it('Should have correct name and symbol', async function () {
      expect(await nftContract.name()).to.equal('NFT Collection');
      expect(await nftContract.symbol()).to.equal('NFT');
    });

    it('Should have correct maxSupply', async function () {
      expect(await nftContract.maxSupply()).to.equal(10000);
    });

    it('Should start with totalSupply of 0', async function () {
      expect(await nftContract.totalSupply()).to.equal(0);
    });
  });

  describe('Minting', function () {
    it('Should mint token successfully', async function () {
      await expect(nftContract.mint(addr1.address, 1)).to.emit(nftContract, 'Transfer').withArgs(ethers.ZeroAddress, addr1.address, 1);
      expect(await nftContract.balanceOf(addr1.address)).to.equal(1);
      expect(await nftContract.ownerOf(1)).to.equal(addr1.address);
      expect(await nftContract.totalSupply()).to.equal(1);
    });

    it('Should not allow non-admin to mint', async function () {
      await expect(nftContract.connect(addr1).mint(addr2.address, 1)).to.be.revertedWith('Only admin can call this');
    });

    it('Should prevent double-minting', async function () {
      await nftContract.mint(addr1.address, 1);
      await expect(nftContract.mint(addr2.address, 1)).to.be.revertedWith('Token already exists');
    });
  });

  describe('Transfers', function () {
    beforeEach(async function () {
      await nftContract.mint(addr1.address, 1);
    });

    it('Should transfer token from owner', async function () {
      await expect(nftContract.connect(addr1).transferFrom(addr1.address, addr2.address, 1)).to.emit(nftContract, 'Transfer').withArgs(addr1.address, addr2.address, 1);
      expect(await nftContract.ownerOf(1)).to.equal(addr2.address);
    });

    it('Should not allow unauthorized transfer', async function () {
      await expect(nftContract.connect(addr2).transferFrom(addr1.address, addr2.address, 1)).to.be.revertedWith('Not authorized');
    });
  });

  describe('Approvals', function () {
    beforeEach(async function () {
      await nftContract.mint(addr1.address, 1);
    });

    it('Should approve token transfer', async function () {
      await expect(nftContract.connect(addr1).approve(addr2.address, 1)).to.emit(nftContract, 'Approval').withArgs(addr1.address, addr2.address, 1);
      expect(await nftContract.getApproved(1)).to.equal(addr2.address);
    });
  });

  describe('Metadata', function () {
    beforeEach(async function () {
      await nftContract.mint(addr1.address, 1);
    });

    it('Should return correct tokenURI', async function () {
      const uri = await nftContract.tokenURI(1);
      expect(uri).to.include('https://api.example.com/metadata/1');
    });
  });

  describe('Pausing', function () {
    it('Should pause minting', async function () {
      await nftContract.pause();
      expect(await nftContract.isPaused()).to.equal(true);
      await expect(nftContract.mint(addr1.address, 1)).to.be.revertedWith('Contract is paused');
    });
  });

  describe('Burning', function () {
    beforeEach(async function () {
      await nftContract.mint(addr1.address, 1);
    });

    it('Should burn token and update balances', async function () {
      await expect(nftContract.connect(addr1).burn(1)).to.emit(nftContract, 'Transfer').withArgs(addr1.address, ethers.ZeroAddress, 1);
      expect(await nftContract.balanceOf(addr1.address)).to.equal(0);
      expect(await nftContract.totalSupply()).to.equal(0);
    });
  });
});
