// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/Pausable.sol";


contract sample_project is Ownable, ERC721A, ReentrancyGuard, Pausable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    using Strings for uint256;

    string baseURI;
    uint256 public cost = 0.1 ether;
    uint public presale_cost = 5 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 50;

    mapping(address => bool) public whitelisted;


    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721A(_name, _symbol) {
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

    function setmaxSupply(uint256 _newmaxSupply) public onlyOwner {
        maxSupply = _newmaxSupply;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setPresaleCost(uint256 _presaleAmount) public onlyOwner {
        presale_cost = _presaleAmount;
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
        _safeMint(msg.sender, _mintAmount);
    }

    function transferToCustomer(address _to, uint256 _mintAmount) public payable onlyOwner whenNotPaused{
        uint256 supply = totalSupply();
        require(_mintAmount > 0, "Mint Amount is 0!");
        require(supply + _mintAmount <= (maxSupply+1), "These many NFTs are not left!");

        _safeMint(_to, _mintAmount);
    }

    function burn(uint256 _tokenId) public {
        _burn(_tokenId);
    }

    function bulkAirdropERC721(address[] calldata _to, uint256[] calldata _amount) public onlyOwner{
        require(_to.length == _amount.length, "Receivers and Amounts are different length!");
        for (uint256 i = 0; i < _to.length; i++) {
        transferToCustomer(_to[i], _amount[i]);
        }
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os, "Withdraw not Successful!");
    }

}