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


contract MasterUranium {
    using SafeMath for uint256;
    uint256 pend;
    address echidna_caller = msg.sender;

    // Info of each user.  

    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 amountWithBonus;
        uint256 bonus;
        uint256 rewardDebt;
    }

    // Info of each pool.
    struct PoolInfo {
        
        uint256 lpSupply;
        uint256 accRadsPerShare; // Accumulated RADSs per share, times 1e12. See below.
    }

    // The RADS TOKEN!
    mapping (address=> uint256) radsbalance;
    mapping (address=> uint256) depositAccount;
    // Dev address.



    // Info of each user that stakes LP tokens.
    mapping (address => bool) public knownPoolLp;
    // Info of each pool.
    PoolInfo public poolInfo;
    // Info of each user that stakes LP tokens.
     mapping (address => UserInfo) public userInfo;
    uint256 radsTot=100;

    // Last reduction period index
    uint256 public lastReductionPeriodIndex = 0;

    uint256 ai;

    constructor()public {
        ai=0;
        radsTot=10000;
        radsbalance[echidna_caller]=0;
        userInfo[echidna_caller].amount=0;
        userInfo[echidna_caller].bonus=0;
        depositAccount[echidna_caller]=100;
        
        // staking pool
        poolInfo=PoolInfo({
            lpSupply: 0,
            accRadsPerShare: 0
            });

    }
   
    function deposit() external{
        require (depositAccount[echidna_caller]>0);
        uint256 _amount=depositAccount[echidna_caller];
        depositAccount[echidna_caller]=0;
        uint256 to_send=userInfo[echidna_caller].bonus-userInfo[echidna_caller].rewardDebt;
        radsbalance[echidna_caller]=radsbalance[echidna_caller].add(to_send);
        radsTot=radsTot.sub(to_send);
        
        if (_amount>0){
            //poolInfo.lpToken.transferFrom(address(echidna_caller), address(this), _amount);
            userInfo[echidna_caller].amount = userInfo[echidna_caller].amount+(_amount);
            userInfo[echidna_caller].bonus=userInfo[echidna_caller].bonus + _amount/2;
        }

        userInfo[echidna_caller].rewardDebt=userInfo[echidna_caller].bonus;
        
    }

    // Withdraw LP tokens from MasterUranium.    

    function emergencyWithdraw() external {
        require(userInfo[echidna_caller].amount>0);
        //poolInfo.lpToken.transfer(address(echidna_caller), userInfo[echidna_caller].amount);
        depositAccount[echidna_caller]+=userInfo[echidna_caller].amount;
        userInfo[echidna_caller].amount = 0;
        userInfo[echidna_caller].rewardDebt=0;
        
    }


    function withdraw(uint256 _amount) public returns (uint256 to_send){
        require(userInfo[echidna_caller].amount >= _amount, "withdraw: not good");
        to_send=userInfo[echidna_caller].bonus-userInfo[echidna_caller].rewardDebt;
        radsbalance[echidna_caller]=radsbalance[echidna_caller].add(to_send);
        depositAccount[echidna_caller]=depositAccount[echidna_caller].add(_amount);
        radsTot=radsTot.sub(to_send);
        if(_amount > 0) {
            userInfo[echidna_caller].amount = userInfo[echidna_caller].amount.sub(_amount);
            userInfo[echidna_caller].bonus= userInfo[echidna_caller].bonus.sub(_amount.div(2));
        } 
        userInfo[echidna_caller].rewardDebt = userInfo[echidna_caller].bonus;
        return to_send;
    }


    function echidna_test_check()public view returns (bool){
        return radsbalance[echidna_caller]<55 || depositAccount[echidna_caller]<100 ;
    }
}

