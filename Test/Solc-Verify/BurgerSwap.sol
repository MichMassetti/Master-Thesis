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


///   @notice invariant __verifier_sum_uint(balances) <= address(this).balance

contract ETHBurgerTransit {
    using SafeMath for uint;
    
    address public owner;
    address public signWallet;
    address public developWallet;
    address public WETH;
    
    uint public totalFee;
    uint public developFee;
    uint256 paybacks;
    
    // key: payback_id
    mapping (uint => bool) public executedMap;
    mapping(address=>uint) balances;
    
    event Transit(address indexed from, address indexed token, uint amount);
    event Withdraw(uint256 paybackId, address indexed to, uint amount);
    event CollectFee(address indexed handler, uint amount);
    
    constructor() public {
        
        owner = msg.sender;
        paybacks=0;
    }
    /// @notice postcondition address(this).balance ==__verifier_old_uint(address(this).balance)+msg.value
    function deposit() public payable returns (uint256){
        balances[msg.sender] += msg.value;
        
        executedMap[paybacks]=false;
        paybacks++;
        return paybacks;
    }
    /// @notice postcondition __verifier_old_uint(address(this).balance)==address(this).balance - _amount
    function withdraw(uint256 _paybackId, uint _amount) public{
        require(executedMap[_paybackId] == false, "ALREADY_EXECUTED");
        
        require(_amount > 0, "NOTHING_TO_WITHDRAW");
        require(_amount<= balances[msg.sender]);
        
        //bytes32 message = keccak256(abi.encodePacked(_paybackId, _token, msg.sender, _amount));
        //require(_verify(message, _signature), "INVALID_SIGNATURE");
        (bool success, ) = address(msg.sender).call{value:_amount}("");
        require(success);
        
        totalFee = totalFee+(developFee);
        
        executedMap[_paybackId] = true;
        balances[msg.sender] -= _amount;
    }
    receive () external payable{
        revert("use the other function for sending money");
    }
    

}