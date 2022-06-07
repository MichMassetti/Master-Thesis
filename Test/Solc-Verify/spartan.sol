library SafeMath {
    /// @notice postcondition c==a+b
    function add(uint256 a, uint256 b) internal pure returns ( uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /// @notice postcondition c==a-b
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
        return c;
    }
    /// @notice postcondition c==a/b
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
        return c;
    }
    /// @notice postcondition c==a*b
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}


contract BEP20{

    using SafeMath for uint256;

    uint256 public  totalSupply;
    // ERC-20 Mappings
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice postcondition value >=0

    function balanceOf(address account) public view returns (uint256 value) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual  returns (uint256) {
        return _allowances[owner][spender];
    }
    // iBEP20 Transfer function

    /// @notice postcondition _balances[msg.sender]<=__verifier_old_uint(_balances[msg.sender])
    /// @notice postcondition _balances[_to]>=__verifier_old_uint(_balances[_to])
    function transfer(address _to, uint256 _value) public  returns (bool success) {
        address _from=msg.sender;
        require(_balances[_from] >= _value, 'BalanceErr');
        require(_balances[_to] + _value >= _balances[_to], 'BalanceErr');
        _balances[_from] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    // iBEP20 Approve function
    function approve(address spender, uint256 amount) public virtual  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    // Internal transfer function


    /// @notice postcondition totalSupply==amount+__verifier_old_uint(totalSupply)
    /// @notice postcondition _balances[account] ==amount+_balances[account] 
    function _mint(address account, uint256 amount) internal {
        totalSupply = totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
    }
    // Burn supply
    function burn(uint256 amount) public virtual {
        _burn(msg.sender, amount);
    }
    /// @notice postcondition _balances[account]>= __verifier_old_uint(_balances[account])-amount
    /// @notice postcondition totalSupply>=__verifier_old_uint(totalSupply)-amount
    /// @notice invariant __verifier_sum_uint(_balances)<=totalSupply
    function _burn(address account, uint256 amount) internal virtual {
        _balances[account] = _balances[account].sub(amount);
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

}

contract Pool {
    using SafeMath for uint256;

    address public BASE;
    address public TOKEN;

    uint256 public one = 10**18;
    uint256 totalSupply =10000;
    uint256 public decimals;
    // ERC-20 Mappings

    uint256 public baseAmount;
    uint256 public tokenAmount;
    uint256 public baseReal;
    uint256 public tokenReal;
    uint256 public fees;
    uint256 public volume;
    uint256 public txCount;

    mapping (address => uint256) balanceToken;
    mapping (address => uint256) balanceBase;
    mapping (address => uint256) balancePool;

    event AddLiquidity(address member, uint256 inputBase, uint256 inputToken, uint256 unitsIssued);
    event RemoveLiquidity(address member, uint256 outputBase, uint256 outputToken, uint256 unitsClaimed);
    event Swapped(address tokenFrom, address tokenTo, uint256 inputAmount, uint256 outputAmount, uint256 fee, address recipient);

    

    constructor (address base, address tok)  payable {
        BASE = base;
        TOKEN = tok;
        decimals = 18;
    }



 

    function charge(uint256 v) public {
        balanceBase[msg.sender]=balanceBase[msg.sender].add(v);
        balanceToken[msg.sender]=balanceToken[msg.sender].add(v);
    }

    /// @notice postcondition baseAmount>=__verifier_old_uint(baseAmount)
    /// @notice postcondition tokenAmount>=__verifier_old_uint(tokenAmount)
    function addLiquidityForMember() public returns(uint256 liquidityUnits){
        uint256 _actualInputBase =balanceBase[address(this)].sub(baseAmount);
        uint256 _actualInputToken = balanceToken[address(this)].sub(tokenAmount);
        
        liquidityUnits = (_actualInputBase.mul(tokenAmount)+_actualInputToken.mul(baseAmount) ).mul(totalSupply).div(2*tokenAmount.mul(baseAmount));

        baseAmount += _actualInputBase;
        tokenAmount += _actualInputToken;
        balancePool [msg.sender]+= liquidityUnits;
        
        return liquidityUnits;
    }
 

    /// @notice invariant  baseAmount==balanceBase[address(this)]
    /// @notice invariant tokenAmount==balanceToken[address(this)]
    /// @notice postcondition balancePool[msg.sender]==0


    function removeLiquidityForMember() public returns (uint256 outputBase, uint256 outputToken) {
        address member= msg.sender;
        require(baseAmount>0);
        require(tokenAmount>0);
        require (balanceBase[msg.sender]>0);

        outputBase = (balancePool[msg.sender].mul(balanceBase[address(this)])).div(totalSupply) ;
        outputToken =(balancePool[msg.sender].mul(balanceToken[address(this)])).div(totalSupply);
        balancePool[msg.sender]=0;
        baseAmount = baseAmount-(outputBase);
        tokenAmount = tokenAmount-(outputToken); 
        
        //_burn(address(this), units);

        safetranfer_base(member,address(this),outputBase);
        safetranfer_token(member, address(this),outputToken);
        
        return (outputBase, outputToken);
    }



    ///@notice postcondition balanceBase[_from] >=__verifier_old_uint(balanceBase[_from]) -_value
    ///@notice postcondition balanceBase[_to] >=__verifier_old_uint(balanceBase[_to]) + _value
    function safetranfer_base(address _to,address _from, uint256 _value) internal  returns (bool success) {
        
        
        require(balanceBase[_from] >= _value, 'BalanceErr');
        require(balanceBase[_to] + _value >= balanceBase[_to], 'BalanceErr');
        balanceBase[_from] = balanceBase[_from] - _value;
        balanceBase[_to] = balanceBase[_to]+ _value;
        return true;

        
    }
    ///@notice postcondition balanceToken[_from] >=__verifier_old_uint(balanceToken[_from]) - _value
    ///@notice postcondition balanceToken[_to] >=__verifier_old_uint(balanceToken[_to]) + _value
    function safetranfer_token(address _to, address _from,uint256 _value) internal  returns (bool success) {
        require(balanceToken[_from] >= _value, 'BalanceErr');
        require(balanceToken[_to] + _value >= balanceToken[_to], 'BalanceErr');
        balanceToken[_from]+=(_value);
        balanceToken[_to] += _value;
        return true;
    }
    ///@notice postcondition balanceBase[msg.sender] >=__verifier_old_uint(balanceBase[msg.sender]) -_value
    ///@notice postcondition balanceBase[_to] >=__verifier_old_uint(balanceBase[_to]) + _value
    function safetranfer_base_pub(address _to, uint _value) public
        returns (bool success) 
    {
        require(balanceBase[msg.sender] >= _value, 'BalanceErr');
        require(balanceBase[_to] + _value >= balanceBase[_to], 'BalanceErr');
        balanceBase[msg.sender] = (balanceBase[msg.sender]).sub( _value);
        balanceBase[_to] = (balanceBase[_to]).add(_value);
        success=true;
        return success;
    }
    ///@notice postcondition balanceToken[msg.sender] >=__verifier_old_uint(balanceToken[msg.sender]) - _value
    ///@notice postcondition balanceToken[_to] >=__verifier_old_uint(balanceToken[_to]) + _value
    function safetranfer_token_pub(address _to, uint _value) public returns (bool success) 
    {
        require(balanceToken[msg.sender] >= _value, 'BalanceErr');
        require(balanceToken[_to] + _value >= balanceToken[_to], 'BalanceErr');
        balanceToken[msg.sender] = balanceToken[msg.sender].sub(_value);
        balanceToken[_to] = balanceToken[_to].add(_value);
        success=true;
        return success;
    }

}




