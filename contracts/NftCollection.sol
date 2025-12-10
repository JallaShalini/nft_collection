// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract NftCollection is IERC721 {
    string public name = "NFT Collection";
    string public symbol = "NFT";
    uint256 public maxSupply = 10000;
    uint256 public totalSupply = 0;
    string public baseURI = "https://api.example.com/metadata/";
    
    address private admin;
    bool private paused = false;
    
    mapping(uint256 => address) private tokenToOwner;
    mapping(address => uint256) private ownerToBalance;
    mapping(uint256 => address) private tokenToApproved;
    mapping(address => mapping(address => bool)) private ownerToOperators;
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }
    
    modifier validAddress(address addr) {
        require(addr != address(0), "Invalid address");
        _;
    }
    
    constructor() {
        admin = msg.sender;
    }
    
    function balanceOf(address owner) public view validAddress(owner) returns (uint256) {
        return ownerToBalance[owner];
    }
    
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = tokenToOwner[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }
    
    function mint(address to, uint256 tokenId) external onlyAdmin whenNotPaused validAddress(to) {
        require(totalSupply < maxSupply, "Max supply reached");
        require(tokenToOwner[tokenId] == address(0), "Token already exists");
        require(tokenId > 0 && tokenId <= maxSupply, "Invalid token ID");
        
        tokenToOwner[tokenId] = to;
        ownerToBalance[to] += 1;
        totalSupply += 1;
        
        emit Transfer(address(0), to, tokenId);
    }
    
    function burn(uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || msg.sender == admin, "Not authorized");
        
        delete tokenToOwner[tokenId];
        ownerToBalance[owner] -= 1;
        totalSupply -= 1;
        
        if (tokenToApproved[tokenId] != address(0)) {
            delete tokenToApproved[tokenId];
        }
        
        emit Transfer(owner, address(0), tokenId);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) external validAddress(to) {
        _transferFrom(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external validAddress(to) {
        _transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, "");
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external validAddress(to) {
        _transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }
    
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        require(owner == from, "From address is not owner");
        require(msg.sender == owner || msg.sender == tokenToApproved[tokenId] || ownerToOperators[owner][msg.sender], "Not authorized");
        
        tokenToOwner[tokenId] = to;
        ownerToBalance[from] -= 1;
        ownerToBalance[to] += 1;
        
        if (tokenToApproved[tokenId] != address(0)) {
            delete tokenToApproved[tokenId];
        }
        
        emit Transfer(from, to, tokenId);
    }
    
    function approve(address to, uint256 tokenId) external validAddress(to) {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || ownerToOperators[owner][msg.sender], "Not authorized");
        
        tokenToApproved[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function setApprovalForAll(address operator, bool approved) external validAddress(operator) {
        require(msg.sender != operator, "Cannot approve yourself");
        ownerToOperators[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function getApproved(uint256 tokenId) external view returns (address) {
        require(tokenToOwner[tokenId] != address(0), "Token does not exist");
        return tokenToApproved[tokenId];
    }
    
    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return ownerToOperators[owner][operator];
    }
    
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(tokenToOwner[tokenId] != address(0), "Token does not exist");
        return string(abi.encodePacked(baseURI, _uint2str(tokenId)));
    }
    
    function setBaseURI(string memory newBaseURI) external onlyAdmin {
        baseURI = newBaseURI;
    }
    
    function pause() external onlyAdmin {
        paused = true;
    }
    
    function unpause() external onlyAdmin {
        paused = false;
    }
    
    function isPaused() external view returns (bool) {
        return paused;
    }
    
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) internal {
        uint256 size;
        assembly {
            size := extcodesize(to)
        }
        
        if (size > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 response) {
                require(response == IERC721Receiver.onERC721Received.selector, "ERC721Receiver rejected");
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
    
    function _uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
