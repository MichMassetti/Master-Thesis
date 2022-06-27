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
        uint256 lastRewardBlock;  // Last block number that RADSs distribution occurs.
        uint256 accRadsPerShare; // Accumulated RADSs per share, times 1e12. See below.
    }

    // The RADS TOKEN!
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
  

    // Last reduction period index
    uint256 public lastReductionPeriodIndex = 0;

    function getUserBonus(address a) public view returns (uint256){
        return userInfo[a].bonus;
    }
    function getUserAmount(address a) public view returns (uint256){
        return userInfo[a].amount;
    }

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

    function emergencyWithdraw() external {
        require(userInfo[msg.sender].amount>0);
        UserInfo storage user = userInfo[msg.sender];
        //poolInfo.lpToken.transfer(address(msg.sender), user.amount);
        user.amount = 0;
        user.rewardDebt=0;
    }


    function withdraw_(uint256 _amount) public returns (uint256 to_send){
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        to_send=user.bonus-user.rewardDebt;
        if(_amount > 0) {
            user.amount = user.amount - (_amount);
            user.bonus= user.bonus - _amount/2;
        } 
        user.rewardDebt = user.bonus;
        return to_send;
    }

}
