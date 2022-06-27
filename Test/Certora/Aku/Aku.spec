methods {
    getTotalBids() returns (uint256) envfree
    getBidIndex(address) returns (uint256) envfree
    getRefundProgess()returns (uint256) envfree
    getClaimedProject() returns (bool) envfree
    getBidInx() returns (uint256) envfree
    bid_(uint8) 
    processRefunds() 
    claimProjectFunds()
}

rule bid_check(uint8 amount){
    env e;
    uint256 oldTotalBids=getTotalBids();
    uint256 oldBidIndex=getBidInx();

    if (getBidIndex(e.msg.sender)==0){
        bid_(e,amount);
        assert oldBidIndex< getBidInx();
    } else {
        bid_(e,amount);
    }



    assert oldTotalBids < getTotalBids();   
}

rule processRefundsCheck(){
    env e;
    //requires are placed for the setup
    require(getBidInx()==5);
    require (getRefundProgess() < getBidInx());
    uint256 oldRefundProgess = getRefundProgess();

    processRefunds(e);

    assert (oldRefundProgess==getBidInx());


}


rule claimProjectFundsCheck() {
    env e;
    require(getBidInx()>1);
    require (getRefundProgess()==getBidInx());

    claimProjectFunds(e);
    assert getClaimedProject();

}
