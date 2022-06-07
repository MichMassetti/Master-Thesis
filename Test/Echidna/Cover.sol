pragma solidity ^0.7.4;

contract Blacksmith {
    mapping(address => Pool) public pools;
    address _lpToken;
    struct Pool {
        uint256 accRewardsPerToken; // accumulated COVER to the lastUpdated Time
        uint256 lastUpdate; // last accumulated rewards update timestamp
    }
    constructor(){
        address add=0xE0f5206BBD039e7b0592d8918820024e2a7437b9;
        pools[add].accRewardsPerToken=1;
        pools[add].lastUpdate=block.timestamp;
        _lpToken=add;
    }

    function updatePool() public{
        Pool storage pool = pools[_lpToken];
        if(block.timestamp>pool.lastUpdate){
            pool.accRewardsPerToken=pool.accRewardsPerToken+5;
        }
        

    }
    function deposit(uint256 _amount) public{

        Pool memory pool = pools[_lpToken];
        updatePool();

        assert(pool.accRewardsPerToken==pools[_lpToken].accRewardsPerToken);
    }
    function withdraw(uint256 _amount) public{
        updatePool();
        Pool memory pool = pools[_lpToken];
        
        assert(pool.accRewardsPerToken==pools[_lpToken].accRewardsPerToken);
    }

}
