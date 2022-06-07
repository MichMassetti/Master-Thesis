pragma solidity >0.7.0;
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
    /// @notice postcondition z<=x
    /// @notice postcondition z<=y
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view  returns (uint256);
    // iBEP20 Transfer function
    function transfer(address to, uint256 value) external  returns (bool success) ;
    // iBEP20 Approve function
    function approve(address spender, uint256 amount)external  returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    function burn(uint256 amount)external;
    function burnFrom(address from, uint256 value) external  ;

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @pancakeswap/pancake-swap-lib/contracts/utils/Address.sol

contract BEP20 is IBEP20{

    using SafeMath for uint256;
    string name;
    uint256 public  totalSupply;
    // ERC-20 Mappings
    mapping(address => uint) public _balances;
    mapping(address => mapping(address => uint)) public _allowances;



    constructor() {
        name="Pool";
    }
    function balanceOf(address account) override external view returns (uint256)  {
        return _balances[account];
    }
    function allowance(address owner, address spender) override public view virtual  returns (uint256) {
        return _allowances[owner][spender];
    }
    // iBEP20 Transfer function
    function transfer(address to, uint256 value) override external  returns (bool success) {
        _transfer(msg.sender, to, value);
        return true;
    }
    // iBEP20 Approve function
    function approve(address spender, uint256 amount)override public virtual  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    // iBEP20 TransferFrom function
    function transferFrom(address from, address to, uint256 value)override public  returns (bool success) {
        require(value <= _allowances[from][msg.sender], 'AllowanceErr');
        _allowances[from][msg.sender] = _allowances[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    // Internal transfer function
    function _transfer(address _from, address _to, uint256 _value) private {
        require(_balances[_from] >= _value, 'BalanceErr');
        require(_balances[_to] + _value >= _balances[_to], 'BalanceErr');
        _balances[_from] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
   
    
    // Contract can mint
    function _mint(address account, uint256 amount) internal {
        totalSupply = totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    // Burn supply
    function burn(uint256 amount)override public virtual {
        _burn(msg.sender, amount);
    }
    function burnFrom(address from, uint256 value)override public virtual  {
        require(value <= _allowances[from][msg.sender], 'AllowanceErr');
        _allowances[from][msg.sender] -= value;
        _burn(from, value);
    }
    function _burn(address account, uint256 amount) internal virtual {
        _balances[account] = _balances[account].sub(amount, "BalanceErr");
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

}


/**
 * @dev Collection of functions related to the address type
 */
library Address {

  
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

 

    
}
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract MasterUranium is Ownable{
    using SafeMath for uint256;
    uint256 pend;
    // Info of each user.  

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 amountWithBonus;
        uint256 bonus;
        uint256 rewardDebt;
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 lpSupply;
        uint256 lastRewardBlock;  // Last block number that RADSs distribution occurs.
        uint256 accRadsPerShare; // Accumulated RADSs per share, times 1e12. See below.
    }

    // The RADS TOKEN!
    BEP20 public rads;
    mapping (address=> uint256) userBonus;
    // Dev address.
    address public devaddr;
    // RADS tokens created per block.
    uint256 public radsPerBlock;
    // Deposit Fee address
    address public feeAddress;


    // Info of each user that stakes LP tokens.
    mapping (address => bool) public knownPoolLp;
    // Info of each pool.
    PoolInfo public poolInfo;
    // Info of each user that stakes LP tokens.
     mapping (address => UserInfo) public userInfo;
  
    // The block number when RADS mining starts.
    uint256 public immutable startBlock;

    // Initial emission rate: 1 RADS per block.
    uint256 public immutable initialEmissionRate;
    // Minimum emission rate: 0.1 RADS per block.
    uint256 public immutable minimumEmissionRate = 100;
    // Reduce emission every 9,600 blocks ~ 12 hours.
    uint256 public immutable emissionReductionPeriodBlocks = 14400;
    // Emission reduction rate per period in basis points: 3%.
    uint256 public immutable emissionReductionRatePerPeriod = 300;
    // Last reduction period index
    uint256 public lastReductionPeriodIndex = 0;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        BEP20 _rads,
        address _devaddr,
        uint256 _radsPerBlock,
        uint256 _startBlock
    ) public {
        
        rads = _rads;
        radsPerBlock = _radsPerBlock;
        startBlock = _startBlock;
        initialEmissionRate = _radsPerBlock;

        // staking pool
        poolInfo=PoolInfo({
            lpToken: _rads,
            lpSupply: 0,
            lastRewardBlock: _startBlock,
            accRadsPerShare: 0
            });

    }
    /// @notice invariant userInfo[msg.sender].bonus>=0
    /// @notice invariant userInfo[msg.sender].amount>=0
    /// @notice postcondition __verifier_old_uint(userInfo[msg.sender].bonus)<=userInfo[msg.sender].bonus
    /// @notice postcondition __verifier_old_uint(userInfo[msg.sender].amount)<=userInfo[msg.sender].amount 

    function deposit(uint256 _amount) external{

        UserInfo storage user = userInfo[msg.sender]; 

        uint256 to_send=user.bonus-user.rewardDebt;
        //safeRadsTransfer(msg.sender,to_send);
        if (_amount>0){
            //poolInfo.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount+(_amount);
            user.bonus=user.bonus + _amount/2;
        }

        user.rewardDebt=user.bonus;
        
    }

    // Withdraw LP tokens from MasterUranium.    

    /// @notice postcondition userInfo[msg.sender].amount==0
    function emergencyWithdraw() external {
        require(userInfo[msg.sender].amount>0);
        UserInfo storage user = userInfo[msg.sender];
        //poolInfo.lpToken.transfer(address(msg.sender), user.amount);
        user.amount = 0;
        user.rewardDebt=0;
    }

    function safeRadsTransfer(address _to, uint256 _amount) internal {
        require(_amount>0);
        uint256 radsBal = rads.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > radsBal) {
            transferSuccess = rads.transfer(_to, radsBal);
        } else {
            transferSuccess = rads.transfer(_to, _amount);
        }
        require(transferSuccess, "safeRadsTransfer: Transfer failed");
    }
    /// @notice invariant userInfo[msg.sender].bonus>=0
    /// @notice invariant userInfo[msg.sender].amount>=0
    /// @notice postcondition userInfo[msg.sender].bonus< __verifier_old_uint(userInfo[msg.sender].bonus)
    /// @notice postcondition userInfo[msg.sender].amount<= __verifier_old_uint(userInfo[msg.sender].amount)
    /// @notice postcondition to_send>=0
    //one suppoert function: when it sends rewards, the bonus must decrease 
    function withdraw_(uint256 _amount) public returns (uint256 to_send){
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        to_send=user.bonus-user.rewardDebt;
        if (to_send>0){
            send(_amount,user);
            return to_send;
        }else  if(_amount > 0) {
            user.amount = user.amount - (_amount);
            user.bonus= user.bonus - _amount/2;
        } 
        user.rewardDebt = user.bonus;
        return to_send;
    }
    /// @notice precondition _amount>=0
    /// @notice postcondition userInfo[msg.sender].bonus< __verifier_old_uint(userInfo[msg.sender].bonus)
    function send(uint256 _amount,UserInfo storage user ) internal {
        if(_amount > 0) {
            user.amount = user.amount - (_amount);
            user.bonus= user.bonus - _amount/2;
        } 
        user.rewardDebt = user.bonus;
    }
}

