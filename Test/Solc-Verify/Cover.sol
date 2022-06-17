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

contract Blacksmith {
    using SafeMath for uint256;
    Pool public pool;
    address _lpToken=0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
    mapping (address => Miner) miners;
    mapping (address => uint256) balances;
    
    uint256 totalSupply=1000;

    struct Miner{
        uint256 rewardWriteoff;
        uint256 amount;
    }

    struct Pool {
        uint256 accRewardsPerToken; // accumulated COVER to the lastUpdated Time
        uint256 lastUpdate; // last accumulated rewards update timestamp
    }
    constructor(){
        pool.accRewardsPerToken=1;
        pool.lastUpdate=block.timestamp;
    }
    /// @notice postcondition pool.accRewardsPerToken>=__verifier_old_uint(pool.accRewardsPerToken)
    function updatePool() public{
       
        if(block.timestamp>pool.lastUpdate){
            pool.accRewardsPerToken=pool.accRewardsPerToken+1;
        }
    }

    /// @notice postcondition  miners[msg.sender].rewardWriteoff==miners[msg.sender].amount + pool.accRewardsPerToken

    function deposit(uint256 _amount) public{
        Miner storage miner = miners[msg.sender];
        Pool memory _pool = pool;
        updatePool();
        miner.amount = miner.amount.add(_amount);
        miner.rewardWriteoff = miner.amount.add(_pool.accRewardsPerToken);
    }

    /// @notice invariant _amount>0
    /// @notice postcondition miners[msg.sender].amount<__verifier_old_uint(miners[msg.sender].amount)
    /// @notice postcondition miners[msg.sender].amount<__verifier_old_uint(miners[msg.sender].amount)
    function withdraw(uint256 _amount) public{
        require(_amount>0);
        updatePool();
        Miner storage miner = miners[msg.sender];
        Pool memory _pool = pool;
        //_claimCoverRewards(_pool,miner);
        miner.amount = miner.amount.sub(_amount);
        miner.rewardWriteoff = miner.amount.mul(_pool.accRewardsPerToken);        
    }


    

}