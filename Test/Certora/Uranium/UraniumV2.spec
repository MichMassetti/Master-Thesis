methods {
    getUserBonus(address) returns (uint256) envfree
    getUserAmount(address) returns (uint256) envfree
    deposit(uint256)
    emergencyWithdraw()
    withdraw_(uint256) returns (uint256)
}


rule withdraw_check (uint256 amount){
    env e;
    uint256 oldbonus=getUserBonus(e.msg.sender);
    uint256 oldamount=getUserAmount(e.msg.sender);
    deposit(e,amount+amount);
    uint256 value= withdraw_(e,amount);
    if (value>0){
        assert getUserBonus(e.msg.sender) < oldbonus ; 
    } 

    assert getUserAmount(e.msg.sender)== oldamount - amount ;

    

}

rule deposit_check (uint256 amount){
    env e;
    uint256 oldbonus=getUserBonus(e.msg.sender);
    uint256 oldamount=getUserAmount(e.msg.sender);

    deposit(e,amount);

    assert oldbonus+amount==getUserBonus(e.msg.sender) ;
    assert oldamount+amount==getUserAmount(e.msg.sender) ;

}
rule emergencyWithdraw_check(uint256 amount){
    env e;
    deposit(e,amount);
    emergencyWithdraw(e);
    assert 0==getUserAmount(e.msg.sender) ;
}