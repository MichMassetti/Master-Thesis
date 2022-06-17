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

///   @notice invariant __verifier_sum_uint(balances) <= totalSupply
contract LoanTokenLogicStandard {

    using SafeMath for uint256;
    uint256 count;
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    uint256 totalSupply;

    constructor () {
        count=0;
        totalSupply=10000000000;
    
    }

    /// @notice postcondtion  balances[msg.sender]= __verifier_old_uint(balances[msg.sender])+v
    
    function charge(uint256 v) public{
        count=count.add(v);
        require(count<=totalSupply);
        balances[msg.sender]=  balances[msg.sender].add(v);
    }

    /// @notice postcondition __verifier_old_uint(balances[msg.sender])>=balances[msg.sender]
    /// @notice postcondition __verifier_old_uint(balances[_to])<=balances[_to]

    function transfer(
        address _to,
        uint256 _value)
        external
        returns (bool)
    {   
        require(_value>0);
        return _internalTransferFrom(
            msg.sender,
            _to,
            _value
        );
    }


    /// @notice postcondition __verifier_old_uint(balances[_from])>=balances[_from]
    /// @notice postcondition __verifier_old_uint(balances[_to])<=balances[_to]

    function transferFrom(
        address _from,
        address _to,
        uint256 _value)
        external
        returns (bool)
    {
        require(_value>0);
        return _internalTransferFrom(
            _from,
            _to,
            _value);
    }
    ///@notice precondtion _value>=0
    /// @notice postcondition __verifier_old_uint(balances[_from])-_value==balances[_from]
    /// @notice postcondition __verifier_old_uint(balances[_to])+ _value==balances[_to] 

    function _internalTransferFrom(
        address _from,
        address _to,
        uint256 _value)
        internal
        returns (bool)
    {
        require(balances[_from]>= _value);
        uint256 _balancesFrom = balances[_from];
        uint256 _balancesTo = balances[_to];

        require(_to != address(0), "15");

        uint256 _balancesFromNew = _balancesFrom
            .sub(_value, "16");
        balances[_from] = _balancesFromNew;

        uint256 _balancesToNew = _balancesTo
            .add(_value);
        balances[_to] = _balancesToNew;

        return true;
    }

}