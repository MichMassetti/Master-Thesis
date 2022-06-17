pragma solidity >=0.7.0;
library SafeMath {

    /// @notice postcondition c==a*b
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }
    /// @notice postcondition c==a+b

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
         c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /// @notice postcondition c==a-b

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return (c=sub(a, b, 'SafeMath: subtraction overflow'));
    }

  
    /// @notice postcondition c==a-b

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256 c) {
        require(b <= a, errorMessage);
        c = a - b;

        return c;
    }

      /// @notice postcondition c==a/b
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return (c=div(a, b, 'SafeMath: division by zero'));
    }

    
    /// @notice postcondition c==a/b

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256 c) {
        require(b > 0, errorMessage);
        c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    
    /// @notice postcondition z<=x
    /// @notice postcondition z<=y
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
}





pragma solidity >=0.7.0;

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 *  see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 {
    using SafeMath for uint256;
    uint256 public owners_size=0;
    uint256 totalSupply=10000;

    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) public _owners;

    // Mapping owner address to index to tokenId
    mapping(address => uint256) private _balances;


    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor() {
        _name ="name";
        _symbol = "symbol_";
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */

    
    function ownerOf(uint256 tokenId) public view virtual  returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function totalSupply_() public view returns(uint256){
        return totalSupply;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view  returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view  returns (string memory) {
        return _symbol;
    }
    ///@notice postcondition balances[from]<balances[from]
    ///@notice postcondition balances[to]<balances[to]
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual  {
        require (from!=to);
        _transfer(from, to, tokenId);
    }

    ///@notice postcondition balances[from]<=__verifier_old(balances[from])
    ///@notice postcondition __verifier_old(balances[to])<=balances[to]

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require (from!=to);

        safeTransferFrom(from, to, tokenId, "");
    }

    ///@notice postcondition balances[from]<=__verifier_old(balances[from])
    ///@notice postcondition __verifier_old(balances[to])<=balances[to]
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        require (from!=to);
        _safeTransfer(from, to, tokenId, _data);
    }


    ///@notice invariant __verifier_sum_uint(_balances)<=owners_size
    ///@notice modifies owners_size
    ///@notice modifies _owners
    ///@notice modifies _balances
    function _safeMint(address to, uint256 tokenId) internal virtual {
       _owners[tokenId] = to;
        owners_size++;
        _balances[to] += 1;

        (bool success, ) = to.call{ value: 0 }("");
        require(true, "ERC721: transfer to non ERC721Receiver implementer"); 
    }


    ///@notice postcondition balances[from]<=__verifier_old(balances[from])
    ///@notice postcondition __verifier_old(balances[to])<=balances[to]
    ///@notice precondition from!=to
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
    }

    
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }



    ///@notice precondition  _owners[tokenId]!= address(0)
    ///@notice postcondition _balances[from]==_balances[from]-1
    ///@notice postcondition _balances[to]==_balances[to]+1
    ///@notice postcondition _balances[to]==_balances[to]+1
    ///@notice precondition from!=to

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");


        // Clear approvals from the previous owner

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

    }


}



// I deleted the possibility of the Owner to publish more ticket
// sum of total claimed NFTs (1 ticket 1 NFT) <= max Number of NFTs, but no ticket can be added if exceed maxNFTSupply
//so reentrancy
/// @notice invariant totalClaimednum == effclaimed
/// @notice invariant __verifier_sum_uint(totalClaimed) <= effclaimed
contract DirtyDogs is ERC721{
    uint256 totalClaimednum=0;
    uint256 effclaimed=0;
    mapping (address=>uint256)totalClaimed;

    function claimDogs() public {
        uint256 numbersOfTickets = 5 ;
        ///@notice postcondition i==numbersOfTickets
        ///@notice postcondition __verifier_old_uint(effclaimed)==effclaimed+numbersOfTickets
        for(uint256 i = 0; i < numbersOfTickets; i++) {
            uint256 mintIndex = totalSupply_();
            effclaimed++;
            _safeMint(msg.sender, mintIndex);
            //msg.sender.call{ value: 0 }("");
        }
        totalClaimednum=totalClaimednum+(numbersOfTickets);
        totalClaimed[msg.sender] = numbersOfTickets+(totalClaimed[msg.sender]);
    }
}
