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
    bool flag;

    mapping (address => uint256) balanceToken;
    mapping (address => uint256) balanceBase;
    mapping (address => uint256) balancePool;

    address echidna_caller = msg.sender;
    constructor (){
        
        balanceBase[echidna_caller]=100;
        balanceToken[echidna_caller]=100;
        balancePool[echidna_caller]=0;
        baseAmount=1000;
        tokenAmount=1000;
        balanceBase[address(this)]=1000;
        balanceToken[address(this)]=1000;
        flag=true;

        
    }


    function safetranfer_base(address _to,address _from, uint256 _value) internal  returns (bool success) {
        
        
    
        balanceBase[_from] = balanceBase[_from].sub(_value) ;
        balanceBase[_to] = balanceBase[_to].add(_value); 
        flag=false;

        return true;

        
    }

    function safetranfer_token(address _to, address _from,uint256 _value) internal  returns (bool success) {
        
        balanceToken[_from]=balanceToken[_from].sub(_value);
        balanceToken[_to] =balanceToken[_to].add(_value) ;
        flag=false;

        return true;
    }
 
    function safetranfer_base_pub(address _to, uint _value) public
        returns (bool success) 
    {
    
        balanceBase[msg.sender] = (balanceBase[msg.sender]).sub( _value);
        balanceBase[_to] = (balanceBase[_to]).add(_value);
        success=true;
                flag=false;

        return success;
    }
  
    function safetranfer_token_pub(address _to, uint _value) public returns (bool success) 
    {
        require(balanceToken[msg.sender] >= _value, 'BalanceErr');
        require(balanceToken[_to] + _value >= balanceToken[_to], 'BalanceErr');
        balanceToken[msg.sender] = balanceToken[msg.sender].sub(_value);
        balanceToken[_to] = balanceToken[_to].add(_value);
        success=true;
        
        return success;
    }    
    function addLiquidityForMember() public returns(uint256 liquidityUnits){
        uint256 _actualInputBase =balanceBase[address(this)].sub(baseAmount);
        uint256 _actualInputToken = balanceToken[address(this)].sub(tokenAmount);
        
        liquidityUnits = (_actualInputBase.mul(tokenAmount)+_actualInputToken.mul(baseAmount) ).mul(totalSupply).div(2*tokenAmount.mul(baseAmount));

        baseAmount += _actualInputBase;
        tokenAmount += _actualInputToken;
        balancePool [msg.sender]+= liquidityUnits;
        
        return liquidityUnits;
    }
 
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
        
        

        safetranfer_base(member,address(this),outputBase);
        safetranfer_token(member, address(this),outputToken);
        flag=false;
        return (outputBase, outputToken);
    }

    function echidna_test_balance() public view  returns (bool){
        return balanceBase[echidna_caller]<=100;
    }  
    

}
