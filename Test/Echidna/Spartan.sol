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


    constructor (){
        address a=0x1aca0511a8A106aC7eEE3E069999F18F980a50A4;
        balanceBase[a]=100;
        balanceToken[a]=100;
        balancePool[a]=100;
        baseAmount=1000;
        tokenAmount=1000;
        balanceBase[address(this)]=1000;
        balanceToken[address(this)]=1000;
        flag=true;

        
    }


    function safetranfer_base(address _from, address _to, uint256 _value) internal  returns (bool success) {
        
        
        balanceBase[_from] = balanceBase[_from].sub(_value);
        balanceBase[_to] = balanceBase[_to].add(_value);
        flag=false;

        return true;

        
    }

    function safetranfer_token( address _from, address _to,uint256 _value) internal  returns (bool success) {
     
        balanceToken[_from] = balanceToken[_from].sub(_value);
        balanceToken[_to] = balanceToken[_to].add(_value);
                flag=false;

        return true;
    }
 
    function safetranfer_base_pub(address _to, uint _value) public
        returns (bool success) 
    {
        require(balanceBase[msg.sender] >= _value, 'BalanceErr');
        require(balanceBase[_to] + _value >= balanceBase[_to], 'BalanceErr');
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
    function removeLiquidityForMember() public returns (uint256 outputBase, uint256 outputToken) {
       
        require(baseAmount>0, "error");
        require(tokenAmount>0, "error");
        require (balancePool[msg.sender]> 0, "error"); 
        address member= msg.sender;

        outputBase = 10 ;
        outputToken =10;
        balancePool[msg.sender]=0;
        baseAmount = baseAmount.sub(outputBase);
        tokenAmount = tokenAmount.sub(outputToken); 
        
        //_burn(address(this), units);

        safetranfer_base(address(this),member,outputBase);
        safetranfer_token(address(this),member,outputToken);
        assert(tokenAmount==balanceToken[address(this)]);
        assert(baseAmount==balanceBase[address(this)]);
        return (outputBase, outputToken);
    }
    

}





