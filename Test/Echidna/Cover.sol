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
    mapping(address => Pool) public pools;
    mapping(address => uint256) public minersReward;
    mapping(address => uint256) public minersRewardEff;
    address echidna_caller = msg.sender;

    address _lpToken;
    struct Pool {
        uint256 accRewardsPerToken; // accumulated COVER to the lastUpdated Time
        uint256 lastUpdate; // last accumulated rewards update timestamp
    }
    constructor() public {
        address add=0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
        pools[add].accRewardsPerToken=1;
        pools[add].lastUpdate=block.timestamp;
        _lpToken=add;
    }

    function updatePool() public{
        Pool storage pool = pools[_lpToken];
        if(block.timestamp>pool.lastUpdate){
            pool.accRewardsPerToken=pool.accRewardsPerToken+5;
            pool.lastUpdate=block.timestamp;
        }
        

    }
    function deposit(uint256 _amount) public{

        Pool memory pool = pools[_lpToken];
        Pool storage pooleff = pools[_lpToken];
        updatePool();
        minersReward[echidna_caller]=minersReward[echidna_caller].add(pool.accRewardsPerToken);
        minersRewardEff[echidna_caller]=minersRewardEff[echidna_caller].add(pooleff.accRewardsPerToken);
    }


    function echidna_test_check()public view returns (bool){
        return minersReward[echidna_caller]== minersRewardEff[echidna_caller];

    }

}
