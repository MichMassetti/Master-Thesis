contract MasterUranium {

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
        radsbalance[echidna_caller]=radsbalance[echidna_caller]+(to_send);
        radsTot=radsTot-(to_send);
        
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
        radsbalance[echidna_caller]=radsbalance[echidna_caller]+(to_send);
        depositAccount[echidna_caller]=depositAccount[echidna_caller]+(_amount);
        radsTot=radsTot-(to_send);
        if(_amount > 0) {
            userInfo[echidna_caller].amount = userInfo[echidna_caller].amount-(_amount);
            userInfo[echidna_caller].bonus= userInfo[echidna_caller].bonus-(_amount/(2));
        } 
        userInfo[echidna_caller].rewardDebt = userInfo[echidna_caller].bonus;
        return to_send;
    }


    function crytic_test_check()public view returns (bool){
        return radsbalance[echidna_caller]<55 || depositAccount[echidna_caller]<100 ;
    }
}

