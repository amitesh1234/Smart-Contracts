// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract FunkyMaestro is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    using Strings for uint256;

    string baseURI;
    uint256 public cost = 10 ether;
    uint public presale_cost = 5 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 50;

    mapping(address => bool) public whitelisted;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setPresaleCost(uint256 _presaleAmount) public onlyOwner {
        presale_cost = _presaleAmount;
    }

    function setmaxSupply(uint256 _newmaxSupply) public onlyOwner {
        maxSupply = _newmaxSupply;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function addWhitelistedUsers(address[] memory _addresses) public onlyOwner {
        for(uint i=0;i<_addresses.length;i++) {
            whitelisted[_addresses[i]] = true;
        }
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelisted[_address];
    }

    /////////////////////////// MINTING CODE STARTS HERE

    function mint(uint256 _mintAmount) public payable whenNotPaused {
        uint256 supply = _tokenIdCounter.current();
        require(_mintAmount > 0, "Mint Amount is 0!");
        require(_mintAmount <= maxMintAmount, " Maximum allowed mint amount exceeded!");
        require(supply + _mintAmount <= (maxSupply+1), "These many NFTs are not left!");

        if (msg.sender != owner()) {
            if(whitelisted[msg.sender]) {
                require(msg.value >= presale_cost * _mintAmount);
            }
            else {
                require(msg.value >= cost * _mintAmount);
            }
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(msg.sender, _tokenIdCounter.current());
            _tokenIdCounter.increment();
        }
    }

    function transferToCustomer(address _to, uint256 _mintAmount) public payable onlyOwner whenNotPaused{
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "Mint Amount is 0!");
        require(supply + _mintAmount <= (maxSupply+1), "These many NFTs are not left!");

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, _tokenIdCounter.current());
            _tokenIdCounter.increment();
        }
    }
    
    function bulkAirdropERC721(address[] calldata _to, uint256[] calldata _amount) public onlyOwner{
        require(_to.length == _amount.length, "Receivers and Amounts are different length!");
        for (uint256 i = 0; i < _to.length; i++) {
        transferToCustomer(_to[i], _amount[i]);
        }
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}