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

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    /// @notice postcondition c==a-b

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return (c=sub(a, b, 'SafeMath: subtraction overflow'));
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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


/// @notice invariant __verifier_sum_uint(_balances) <= _totalSupply
contract SurgedecimalToken {
    
    using SafeMath for uint256;
    using SafeMath for uint8;

    // token data
    string constant _name = "Surge";
    string constant _symbol = "SURGE";
    uint8 constant _decimals = 0;
    // 1 Billion Total Supply
    uint256 _totalSupply = 1 * 10**9;
    // balances
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowances;

    uint256 public sellFee = 94;
    uint256 public spreadDivisor = 94;
    uint256 public transferFee = 98;
    bool public hyperInflatePrice = false;
    
    
    
    // initialize some stuff
    constructor  () {
        // exempt this contract, the LP, and OUR burn wallet from receiving Safemoon Rewards
        _balances[msg.sender] = _totalSupply;
    }
    
    ///@notice postcondtion c>=0
    function calculatePrice() public view returns (uint256 c) {
        c=((address(this).balance)/(_totalSupply));
        require (c>=0);
        return c;
        
    }
    //total supply can't grow, there is a reentrancy which allow the totalSupply to grow -> call the purchase 
    /// @notice postcondition v>=0
    /// @notice postcondition _totalSupply <= __verifier_old_uint(_totalSupply)
    
    /// @notice postcondition __verifier_old_uint(address(this).balance)==address(this).balance-tokenAmount
    
    function sell(uint256 tokenAmount) public returns (uint256 v) {
        
        address seller = msg.sender;
        
        // make sure seller has this balance
        require(_balances[seller] >= tokenAmount, 'cannot sell above token amount');
        
        
        // how much BNB are these tokens worth?
        uint256 amountBNB = tokenAmount;
        
        v=amountBNB;
        (bool successful,) = payable(seller).call{value: amountBNB, gas: 40000}("");
        if (successful) {
            // subtract full amount from sender
            _balances[seller] = _balances[seller]-(tokenAmount);
            // if successful, remove tokens from supply
            _totalSupply = _totalSupply-(tokenAmount);

        } else {
            revert();
        }
        return v;
    }

    /// @notice precondition amount >0
    /// @notice postcondition __verifier_old_uint (_totalSupply )<= _totalSupply 
    /// @notice postcondition __verifier_old_uint (_balances[receiver] )<= _balances[receiver]

    function mint(address receiver, uint amount) internal {
        _balances[receiver] = _balances[receiver]+(amount);
        _totalSupply = _totalSupply+(amount);
    }


   /// @notice  modifies _totalSupply
   /// @notice modifies _balances
    function purchase(address buyer, uint256 bnbAmount) internal returns (bool) {
        // make sure we don't buy more than the bnb in this contract
        require(bnbAmount <= address(this).balance, 'purchase not included in balance');
        // previous amount of BNB before we received any        
        uint256 prevBNBAmount = (address(this).balance).sub(bnbAmount);
        // if this is the first purchase, use current balance
        prevBNBAmount = prevBNBAmount == 0 ? address(this).balance : prevBNBAmount;
        // find the number of tokens we should mint to keep up with the current price
        uint256 nShouldPurchase = hyperInflatePrice ? _totalSupply.mul(bnbAmount).div(address(this).balance) : _totalSupply.mul(bnbAmount).div(prevBNBAmount);
        // apply our spread to tokens to inflate price relative to total supply
        uint256 tokensToSend = nShouldPurchase.mul(spreadDivisor).div(10**2);
        // revert if under 1
        if (tokensToSend < 1) {
            revert('Must Buy More Than One Surge');
        }
        
        // mint the tokens we need to the buyer
        mint(buyer, tokensToSend);
        return true;
    }
    /// @notice  modifies _totalSupply
    /// @notice modifies _balances
    receive () external payable {
        uint256 val = msg.value;
        address buyer = msg.sender;
        purchase(buyer, val);
    }



/* 
        NOTES
Mich 10 Surge Contract 100 bnb Supply 100 Surge 
Mich sell 10 surge ->10 BNB
not updated my balance and total supply 10 surge 
Mich 10 surge , Contract -10BNB -> 90 BNB
Mich purchase 10 BNB just received for 10 Surge 
Mich 20 Surge Contract: 100 BNB totalSupply 110 Surge 
*/
}
