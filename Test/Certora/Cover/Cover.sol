library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
         c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return (c=sub(a, b, 'SafeMath: subtraction overflow'));
    }

  

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256 c) {
        require(b <= a, errorMessage);
        c = a - b;

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return (c=div(a, b, 'SafeMath: division by zero'));
    }

    

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

    function updatePool() public{
       
        if(block.timestamp>pool.lastUpdate){
            pool.accRewardsPerToken=pool.accRewardsPerToken+block.timestamp-pool.lastUpdate;
            pool.lastUpdate=block.timestamp;
        }

    }   

    function getAmount(address a) public view returns (uint256){
        return miners[a].amount;
    }
    function getRewardWriteoff(address a) public view returns (uint256){
        return miners[a].rewardWriteoff;
    }
    function getPoolAcc() public view returns (uint256){
        return pool.accRewardsPerToken;
    }




    function deposit(uint256 _amount) public{
        require(_amount>0);
        Miner storage miner = miners[msg.sender];
        Pool memory _pool = pool;
        updatePool();
        claimReward(miner,_pool); 
        miner.amount = miner.amount.add(_amount);
        miner.rewardWriteoff = miner.amount.mul(_pool.accRewardsPerToken);
    }
    


    function withdraw(uint256 _amount) public{
        require(_amount>0);
        require(_amount<=miners[msg.sender].amount);
        updatePool();
        Miner storage miner = miners[msg.sender];
        Pool memory _pool = pool;
        claimReward(miner,_pool);
        miner.amount = miner.amount-(_amount);
        miner.rewardWriteoff = miner.amount.mul(_pool.accRewardsPerToken);        
    }

    //minting function 
    function claimReward(Miner memory miner,Pool memory _pool) private pure returns (uint256 minedSinceLastUpdate) {
        if (miner.amount > 0) {
            minedSinceLastUpdate = miner.amount.mul(_pool.accRewardsPerToken).sub(miner.rewardWriteoff);
        }
        return minedSinceLastUpdate;
        
    }

    

}