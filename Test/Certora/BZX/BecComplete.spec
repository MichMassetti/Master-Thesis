// Pick any of the examples from the sidebar or start from scratch
// myFirstRule{
// 	assert false;
// }

methods {
    balanceOf(address _who) returns (uint256) envfree 
    _internalTransferFrom(address _from,address _to,uint256 _value,uint256 _allowanceAmount)
    transferFrom(address _from,address _to,uint256 _value)
    
}

rule transferFromCheck(address alice, address bob, uint256 amount){
    env e;
    require balanceOf(alice)>amount;
    require allowance(alice, e.msg.sender) >= amount;
    uint256 balanceBefore = balanceOf(bob);
    uint256 balanceAliceBefore = balanceOf(alice);

    transferFrom(e, alice, bob, amount);

    uint256 balanceAfter = balanceOf(bob);
    uint256 balanceAliceAfter = balanceOf(alice);
    assert balanceAfter == balanceBefore + amount;
    assert balanceAliceAfter == balanceAliceBefore - amount;
}