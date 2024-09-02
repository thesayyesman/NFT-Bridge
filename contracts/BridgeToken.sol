//SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

pragma solidity ^0.8.20;

contract NFT is ERC721Enumerable, Ownable(msg.sender) {
    using Strings for uint256;
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public maxSupply = 1000;
    bool public paused = false;

    constructor() ERC721("Fifa World Cup", "FWC") {}

    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://QmYB5uWZqfunBq7yWnamTqoXWBAHiQoirNLmuxMzDThHhi/";
    }

    function bridgeMint(address to, uint256 tokenId) public virtual onlyOwner {
        _mint(to, tokenId);
    }

    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            ownerOf(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    // only owner

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
}
