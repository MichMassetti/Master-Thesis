methods {
    getAmount(address) returns (uint256) envfree
    getRewardWriteoff(address) returns (uint256) envfree
    getPoolAcc() returns (uint256) envfree
    

}
rule deposit_check(uint256 amount){
    
    env e;
    require(amount>0);
    uint256 old_amount=getAmount(e.msg.sender);
    deposit(e,amount);
    uint256 new_amount=getAmount(e.msg.sender);
    assert(old_amount+amount==getAmount(e.msg.sender)), "Error math";
    assert getRewardWriteoff(e.msg.sender)==new_amount*getPoolAcc() , "Missing estimation";
    


}

rule withdraw_check (uint256 amount){
     env e;
    require(amount>0);
    
    uint256 old_amount=getAmount(e.msg.sender);
    withdraw(e,amount);
    uint256 new_amount=getAmount(e.msg.sender);
    assert(old_amount-amount==getAmount(e.msg.sender)), "Error math";
    assert getRewardWriteoff(e.msg.sender)==new_amount*getPoolAcc() , "Missing estimation";
}