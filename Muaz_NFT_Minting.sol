// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// import "@openzeppelin/contracts/access/Ownable.sol";

contract MintPass is ERC721Enumerable {
    address public owner;
    uint256 public constant max_Supply = 1000;
    uint256 public PriceRate = 1 ether;
    uint256 public constant MAxWallet = 7;
    uint256 public constant MintPeriodofTime = 7;
    uint256 public mintStartTime;
    bool public mintingEnabled = true;
    bool private _mintingEnabled = false;
    bool private _whitelistEnabled = false;
    mapping(address => bool) private _whitelist;
    address private Address_fee = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
    string private _baseTokenURI = "https://gateway.pinata.cloud/ipfs/QmToF92ZGLihXcjiHb3GXPdEPV9NnMkkAUhArximxW8Jh2/";
    uint256 private _royaltyPercentage = 7;
        mapping(address => uint256) public mintedTokens;
        mapping (address => uint256) addressToNumberOfTokensMinted;
        bool freeMintPeriod = true;
        mapping (address => uint) public mintCount;
        uint256 private _mintCounts;
        address[] private _mintAddresses;
      constructor() ERC721("Creative Creation Mint Pass", "CCC") {
        owner = msg.sender;
        //  mintingEnabled = true;
          mintStartTime = block.timestamp;
         _mint(msg.sender, 111); // Mint one token for the contract owner
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function mint1(address recipient ,uint256 _numToMint) external payable {
        if (_whitelistEnabled) {
        require(_whitelist[msg.sender], "You are not whitelisted");
        require(totalSupply() + _numToMint <= max_Supply,"Not enough tokens left to mint");
        require( msg.value == _numToMint * PriceRate,"Incorrect payment amount");
        require(_mintCounts[_numToMint] < 7, "You can only mint up to 7 tokens per wallet.");
        uint256 mintedCount = balanceOf(msg.sender);
        require(mintedCount + _numToMint <= MAxWallet,"Exceeded max mint per wallet");
        payable(Address_fee).transfer(msg.value * _royaltyPercentage / 100);

        // require(msg.value >= mintFee, "Insufficient minting fees");
        for (uint256 i = 0; i < _numToMint; i++) {
            uint256 tokenId = totalSupply();
            // _mint(msg.sender, tokenId);
            _safeMint(recipient, tokenId);
        }
        }else{
            require(totalSupply() + _numToMint <= max_Supply,"Not enough tokens left to mint");
            require( msg.value == _numToMint * PriceRate,"Incorrect payment amount");

            uint256 mintedCount = balanceOf(msg.sender);
            require(mintedCount + _numToMint <= MAxWallet,"Exceeded max mint per wallet");
            payable(Address_fee).transfer(msg.value * _royaltyPercentage / 100);

            // require(msg.value >= mintFee, "Insufficient minting fees");
            for (uint256 i = 0; i < _numToMint; i++) {
                uint256 tokenId = totalSupply();
                _mint(recipient, tokenId);
            }
        }
         if (_mintCounts[msg.sender] == 0) {
        _mintAddresses.push(msg.sender);
    }
    _mintCounts[_numToMint] += 1;
    }
    // withoutcost
    event Mint(address indexed _to, uint256 amount);
    function ownerMint(uint256 _numToMint) external onlyOwner {
        require(totalSupply() + _numToMint <= max_Supply,"Not enough tokens left to mint" );

        for (uint256 i = 0; i < _numToMint; i++) {
            uint256 tokenId = totalSupply();
            _mint(msg.sender, tokenId);
            emit Mint( msg.sender,_numToMint);
        }
    }
    //  111 mint passes will be minted right after deployment of the smart contract and the mint passes should go in the owner’s wallet
//    Function to get list of wallet addresses who have minted so far and the amount they’ve minted (Owner only function)
    function getMintedTokensByWallet(address _wallet)external view onlyOwner returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_wallet);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_wallet, i);
        }
        return tokenIds;
    }

    function MintingOnAngOff() public onlyOwner returns (uint256)  {
        if (mintingEnabled) {
            mintingEnabled = false;
            mintStartTime = 0;
        } else {
            mintingEnabled = true;
            mintStartTime = block.timestamp;
        }
         return mintStartTime + MintPeriodofTime * 1 days;
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function transfer(
        address from,
        address to,
        uint256 tokenId
    ) external {
        require(_isApprovedOrOwner(msg.sender, tokenId),"Not approved or not owner.");
        require(ownerOf(tokenId) == from, "Not current owner.");
        _safeTransfer(from, to, tokenId, "");
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }
/*
    // function setMaxMintPerWallet(uint256 maxMintPerWallet) external onlyOwner {
    //     MAxWallet = maxMintPerWallet;
    // }

    // function setMintPrice(uint256 mintPrice) external onlyOwner {
    //     PriceRate = mintPrice;
    // }
// */
    function setMintingEnabled(bool enabled) external onlyOwner {
        _mintingEnabled = enabled;
    }

    function setWhitelistEnabled(bool enabled) external onlyOwner {
        _whitelistEnabled = enabled;
    }

    function addToWhitelist(address wallet) external onlyOwner {
        _whitelist[wallet] = true;
    }

    function removeFromWhitelist(address wallet) external onlyOwner {
        delete _whitelist[wallet];
    }

    function isWhitelisted(address wallet) public view returns (bool) {
        return _whitelist[wallet];
    }
// MintData function should update the count of minted tokens against the wallet address
// instead of making a new entry - and the function should return the list of unique wallet
//  addresses who have minted so far and the amount of tokens every wallet has minted - 
//  this same function should be implemented for owner minting process as well

    // function MintData(uint256 _tokenId) public {
    //     require( msg.sender == owner,"Only the contract owner can mint new tokens" );
    //     for (uint256 i = 0; i < _tokenId; i++) {
    //         uint256 tokenId = totalSupply();
    //         _mint(msg.sender, tokenId);
            
    //         //  mintedTokens(msg.sender) += 1;
    //     }
    //       mintedTokens[msg.sender] += 1;
    // }

 

// function mintData(uint256 _count) external {
//     addressToNumberOfTokensMinted[msg.sender] += _count;
//     if(freeMintPeriod) {
//         require(addressToNumberOfTokensMinted[msg.sender] < 6, "No free mints left!");
//     }

//     // Mint tokens
// }


// function MintData() public view returns (address[] memory, uint[] memory) {
//     address[] memory mintPassList;
//     uint length = 0;
//     for (uint i = 0; i < mintPassList.length; i++) {
//         if (mintCount[mintPassList[i].owner] > 0) {
//             length++;
//         }
//     }
//     address[] memory walletAddresses = new address[](length);
//     uint[] memory mintCounts = new uint[](length);
//     uint j = 0;
//     for (uint i = 0; i < mintPassList.length; i++) {
//         address owner = mintPassList[i].owner;
//         uint count = mintCount[owner];
//         if (count > 0) {
//             walletAddresses[j] = owner;
//             mintCounts[j] = count;
//             j++;
//         }
//     }
//     return (walletAddresses, mintCounts);
// }

function MintData() public view returns (address[] memory, uint256[] memory) {
    uint256[] memory mintAmounts = new uint256[](_mintAddresses.length);
    for (uint256 i = 0; i < _mintAddresses.length; i++) {
        mintAmounts[i] = _mintCounts[_mintAddresses[i]];
    }
    return (_mintAddresses, mintAmounts);
}

// function mint(address recipient) public {
//     // require(_isMintingEnabled(), "Minting is not currently enabled.");
   
//     emit Mint(recipient);
// }

    function getMintedCountByWallet(address _wallet)external view onlyOwner returns (uint256)
    {
        return balanceOf(_wallet);
    }
}

