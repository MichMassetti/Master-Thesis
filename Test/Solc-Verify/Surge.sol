interface IERC20 {

    function decimals() external pure  returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
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


contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

/// @notice invariant __verifier_sum_uint(_balances[__verifier_idx_address]) <= _totalSupply
contract SurgedecimalToken is IERC20, Ownable {
    
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
    function decimals() external pure override  returns (uint8){
        return _decimals;
    }
    function totalSupply() external view override returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address account) external view override returns (uint256){
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) external override returns (bool){
        return _transferFrom(msg.sender, recipient, amount);
    }
    function allowance(address holder, address spender) external view  override returns (uint256) { 
        return _allowances[holder][spender]; 
        }
    function approve(address spender, uint256 amount ) external override returns (bool){
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount )  external  override returns (bool){
        require(sender == msg.sender);
        return _transferFrom(sender, recipient, amount);
    }
    function _transferFrom(address sender, address recipient, uint256 amount) internal  returns (bool) {
        // make standard checks
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // subtract form sender, give to receiver, burn the fee
        uint256 tAmount = amount.mul(transferFee).div(10**2);
        uint256 tax = amount.sub(tAmount);
        // subtract from sender
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        // give reduced amount to receiver
        _balances[recipient] = _balances[recipient].add(tAmount);
        // burn the tax
        _totalSupply = _totalSupply.sub(tax);
        // Transfer Event
        emit Transfer(sender, recipient, tAmount);
        return true;
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
    /// @notice invariant __verifier_sum_uint(_balances) <= _totalSupply
    
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

    /// @notice invariant __verifier_sum_uint(_balances) <= _totalSupply
    /// @notice precondition amount >=0
    /// @notice postcondition __verifier_old_uint (_totalSupply )<= _totalSupply 
    /// @notice postcondition __verifier_old_uint (_balances[receiver] )<= _balances[receiver]

    function mint(address receiver, uint amount) internal {
        _balances[receiver] = _balances[receiver]+(amount);
        _totalSupply = _totalSupply+(amount);
    }
    
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
    receive () external payable {
        uint256 val = msg.value;
        address buyer = msg.sender;
        purchase(buyer, val);
    }
/* Mich 10 Surge Contract 100 bnb Supply 100 Surge 
Mich sell 10 surge ->10 BNB
not updated my balance and total supply 10 surge 
Mich 10 surge , Contract -10BNB -> 90 BNB
Mich purchase 10 BNB just received for 10 Surge 
Mich 20 Surge Contract: 100 BNB totalSupply 110 Surge 

    
*/
}

