// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

contract NFT {
    // Error messages
    error Invalid_Address();
    error Token_Does_Not_Exist();
    error Not_Authorized();
    error Not_Approved();

    //  name and symbol: Public variables representing the name and symbol of the NFT collection.
    string public name;
    string public symbol;

    // _owners: Maps token IDs to their respective owners.
    mapping(uint256 => address) private _owners;

    // _balances: Tracks the number of tokens owned by each address.
    mapping(address => uint256) private _balances;

    // _tokenApprovals: Stores the approved address for a specific token ID.
    mapping(uint256 => address) private _tokenApprovals;

    // _operatorApprovals: Tracks whether an operator is approved to manage all tokens of a specific owner.
    mapping(address => mapping(address => bool)) private _operatorApprovals;


    // _tokenURIs: Stores the metadata URI (e.g., IPFS link) for each token.
    mapping(uint256 => string) private _tokenURIs;

    // _tokenIdCounter: A counter to assign unique token IDs during minting.
    uint256 private _tokenIdCounter;


    // Transfer: Emitted when a token is transferred from one address to another.
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    // Approval: Emitted when an address is approved to manage a specific token.
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    // ApprovalForAll: Emitted when an operator is approved or disapproved to manage all tokens of an owner.
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


    // Initializes the NFT contract with a name and symbol for the collection.
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /**
     * Internal function to transfer ownership of a given token ID to another address.
     * @param from address representing the previous owner of the given token ID
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert Invalid_Address();
        }

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * Checks if an operator is approved to manage all tokens of a specific owner.
     * @param owner address of the token owner
     * @param operator address of the operator
     * @return bool true if the operator is approved, false otherwise
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * Returns the number of tokens owned by a specific address.
     * Reverts if the address is invalid (zero address).
     */
    function balanceOf() external view returns (uint256) {
        if (msg.sender == address(0)) {
            revert Invalid_Address();
        }
        return _balances[msg.sender];
    }

    /**
     * Returns the owner of a specific token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the owner of
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        if (owner == address(0)) {
            revert Token_Does_Not_Exist();
        }
        return owner;
    }

    /**
     * Approves another address to manage the specified token.
     * Reverts if the caller is not the owner of the token.
     * @param to address to be approved for the specified token
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner || !isApprovedForAll(owner, msg.sender)) {
            revert Not_Authorized();
        }
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * Gets the approved address for a token ID, or zero if no address set.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }

    /**
     * Approves or disapproves an operator to manage all of the caller's tokens.
     * @param operator address to be approved or disapproved
     * @param approved bool true to approve, false to disapprove
     */
    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /**
     * Transfers a token from the caller to a given address.
     * Reverts if the caller is not the owner of the token.
     * @param to address to receive the token
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        if (msg.sender != owner || !isApprovedForAll(owner, msg.sender)) {
            revert Not_Authorized();
        }
        _transfer(owner, to, tokenId);
    }

    /**
     * check if the spender is authorized to manage the token
     * @param spender address to spender the token
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view {
        address owner = ownerOf(tokenId);
        if (spender != owner && getApproved(tokenId) != spender && !isApprovedForAll(owner, spender)) {
            revert Not_Approved();
        }
    }

    /**
     * Mints a new token and assigns it to the specified address.
     * Associates a metadata URI with the token.
     * Emits a Transfer event with from set to the zero address (indicating creation).
     * @param to address to receive the minted token
     * @param uri string URI for the token's metadata
     */
    function mint(address to, string memory uri) public {
        require(to != address(0), "Invalid address");

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;

        _balances[to] += 1;
        _owners[tokenId] = to;
        _tokenURIs[tokenId] = uri;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * Returns the metadata URI for a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token to query
     * @return string URI for the token
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        if (_owners[tokenId] == address(0)) {
            revert Token_Does_Not_Exist();
        }
        return _tokenURIs[tokenId];
    }
}
