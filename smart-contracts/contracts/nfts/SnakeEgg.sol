// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract SnakeEgg is AccessControlEnumerable, ERC721Enumerable, ERC721Burnable {

    uint randNonce = 0;

    event BaseURIChanged(string uri);

    uint256 public currentId;

    string private _uri;

    struct Egg {
        uint256 snakeGender;
        uint256 snakeRarity;
    }

    event SnakeEggCreated(uint256 id, address owner, Egg newSnake);

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    constructor(string memory name, string memory symbol, string memory uri) ERC721(name, symbol) {
        _uri = uri;

        _setupRole(MINTER_ROLE, _msgSender());
    }

    function setBaseURI(string memory uri) public virtual {
        require(bytes(uri).length > 0, "SnakeEgg: uri is invalid");

        _uri = uri;

        emit BaseURIChanged(uri);
    }

    function mint(uint256 eggPrice, address to) public virtual payable {
        require(msg.sender.balance >= eggPrice, "Not Enough SNCT");

        //check limitation of each egg type

        _mint(to, ++currentId);

        uint256 snakeGender = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, randNonce))) % 2 ;

        uint256 snakeRarity = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, randNonce))) % 5 ;

        randNonce++;
        
        Egg memory newSnake = Egg(snakeGender, snakeRarity);

        emit SnakeEggCreated(currentId, to, newSnake);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _uri;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}