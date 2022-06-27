

using DummyERC20A as _token0 
using DummyERC20B as _token1

methods{
    token0() returns (address) envfree;
    token1() returns (address) envfree;
    allowance(address,address) returns (uint256) envfree;
    totalSupply()returns uint256 envfree;
    getReserve0() returns uint256 envfree;
    getReserve1() returns uint256 envfree;
    calcLiquidityUnits(uint b, uint B, uint t, uint T, uint P) returns (uint) envfree; 
    calcLiquidityShare(uint units, address token, address pool) public view returns (uint) envfree;
    
    //calls to external contracts  
    _token0.balanceOf(address user) returns (uint256) envfree;
    _token1.balanceOf(address user) returns (uint256) envfree;
    _token0.transfer(address, uint);
    _token1.transfer(address, uint);
    transferFrom(address sender, address recipient, uint256 amount) => DISPATCHER(true);
    balanceOf(address) returns (uint256) envfree => DISPATCHER(true);


    
}

// a function for precondition assumptions 
function setup(env e){
    address zero_address = 0;
    uint256 MINIMUM_LIQUIDITY = 1000;
    require totalSupply() > 0 <=> getReserve0()>0 <=> getReserve1()>0;
    require balanceOf(e.msg.sender) <= totalSupply() && balanceOf(e.msg.sender) >0; 
    require _token0 == token0();
    require _token1 == token1();
}




rule integrityOfSwap(address recipient) {
    env e;
    setup(e);
    require recipient != currentContract;
    uint256 balanceBefore = _token0.balanceOf(recipient);
    uint256 amountOut = swap(_token1, recipient);
    uint256 balanceAfter = _token0.balanceOf(recipient);
    assert balanceAfter == balanceBefore + amountOut; 
}

rule integrityOfRemoveLiquidity(address recipient){
    env e;
    setup(e);
    require recipient != currentContract;

    removeLiquidityForMember(e.msg,sender);

    assert getReserve0()==_token0.balanceOf(currentContract);
}
/*
Property: Only the user itself or an allowed spender can decrease the user's LP balance.

This property is implemented as a parametric rule - it checks all public/external methods of the contract.

This property catches a bug in which there is a switch between the token and the recipient in burnSingle:
        transfer( recipient, tokenOut, amountOut);

Formula:
        { b = balanceOf(account), allowance = allowance(account, e.msg.sender) }
            op by e.msg.sender;
        { balanceOf(account) < b =>  (e.msg.sender == account  ||  allowance >= (before-balanceOf(account)) }
*/

rule noDecreaseByOther(method f, address account) {
    env e;
    setup(e);
    require e.msg.sender != account;
    require account != currentContract; 
    uint256 allowance = allowance(account, e.msg.sender); 
    
    uint256 before = balanceOf(account);
    calldataarg args;
    f(e,args);
    uint256 after = balanceOf(account);
    
    assert after < before =>  (e.msg.sender == account  ||  allowance >= (before-after))  ;
}


/*
Property: For both token0 and token1 the balance of the system is at least as much as the reserves.

This property is implemented as an invariant. 
Invariants are a specification of a condition that should always be true once an operation is concluded.
In addition, the invariant also checks that it holds right after the constructor of the code runs.

This invariant also catches the bug in which there is a switch between the token and the recipient in burnSingle:
        transfer( recipient, tokenOut, amountOut);

Formula:
    getReserve0() <= _token0.balanceOf(currentContract) &&
    getReserve1() <= _token1.balanceOf(currentContract)
*/

invariant balanceGreaterThanReserve()
    (getReserve0() <= _token0.balanceOf(currentContract))&&
    (getReserve1() <= _token1.balanceOf(currentContract))
    {
        preserved with (env e){
         setup(e);
        }
    }


  (totalSupply() == 0 <=> getReserve1() == 0)


invariant integrityOfTotalSupply()
    
    (totalSupply() == 0 <=> getReserve0() == 0) &&
    (totalSupply() == 0 <=> getReserve1() == 0)
    {
        preserved with (env e){
            requireInvariant balanceGreaterThanReserve();
            setup(e);
        }
    }




ghost mathint sumBalances{
    // assuming value zero at the initial state before constructor 
	init_state axiom sumBalances == 0; 
}


hook Sstore _balances[KEY address a] uint256 new_balance
    (uint256 old_balance) STORAGE {
  sumBalances = sumBalances + new_balance - old_balance;
}

invariant sumFunds() 
	sumBalances == totalSupply()
