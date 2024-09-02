//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract bridgeCustody is
    IERC721Receiver,
    ReentrancyGuard,
    Ownable(msg.sender)
{
    uint256 public costCustom = 1 ether;
    uint256 public costNative = 0.000075 ether;

    struct Custody {
        uint256 tokenId;
        address holder;
    }

    mapping(uint256 => Custody) public holdCustody;

    event NFTCustody(uint256 indexed tokenId, address holder);

    ERC721Enumerable nft;
    IERC20 paytoken;

    constructor(ERC721Enumerable _nft, IERC20 _paytoken) {
        nft = _nft;
        paytoken = _paytoken;
    }

    function retainNFTC(uint256 tokenId) public payable nonReentrant {
        require(nft.ownerOf(tokenId) == msg.sender, "NFT not yours");
        require(holdCustody[tokenId].tokenId == 0, "NFT already stored");
        paytoken.transferFrom(msg.sender, address(this), costCustom);
        holdCustody[tokenId] = Custody(tokenId, msg.sender);
        nft.transferFrom(msg.sender, address(this), tokenId);
        emit NFTCustody(tokenId, msg.sender);
    }

    function retainNFTN(uint256 tokenId) public payable nonReentrant {
        require(
            msg.value == costNative,
            "Not enough balance to complete transaction."
        );
        require(nft.ownerOf(tokenId) == msg.sender, "NFT not yours");
        require(holdCustody[tokenId].tokenId == 0, "NFT already stored");
        holdCustody[tokenId] = Custody(tokenId, msg.sender);
        nft.transferFrom(msg.sender, address(this), tokenId);
        emit NFTCustody(tokenId, msg.sender);
    }

    function retainNew(uint256 tokenId) public nonReentrant onlyOwner {
        require(holdCustody[tokenId].tokenId == 0, "NFT already stored");
        holdCustody[tokenId] = Custody(tokenId, msg.sender);
        nft.transferFrom(msg.sender, address(this), tokenId);
        emit NFTCustody(tokenId, msg.sender);
    }

    function updateOwner(
        uint256 tokenId,
        address newHolder
    ) public nonReentrant onlyOwner {
        holdCustody[tokenId] = Custody(tokenId, newHolder);
        emit NFTCustody(tokenId, newHolder);
    }

    function releaseNFT(
        uint256 tokenId,
        address wallet
    ) public nonReentrant onlyOwner {
        nft.transferFrom(address(this), wallet, tokenId);
        delete holdCustody[tokenId];
    }

    function emergencyDelete(uint256 tokenId) public nonReentrant onlyOwner {
        delete holdCustody[tokenId];
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "Cannot Receive NFTs Directly");
        return IERC721Receiver.onERC721Received.selector;
    }

    function withdrawCustom() public payable onlyOwner {
        paytoken.transfer(msg.sender, paytoken.balanceOf(address(this)));
    }

    function withdrawNative() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }
}
