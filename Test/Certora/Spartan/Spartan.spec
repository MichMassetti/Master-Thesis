methods{
    getBaseAmount () returns (uint256) envfree;
    getTokenAmount () returns (uint256) envfree;
    balanceBaseOfThis () returns (uint256) envfree;
    balanceTokenOfThis () returns (uint256) envfree;
    removeLiquidityForMember()
    charge(uint256 v) 
    addLiquidityForMember()
    safetranfer_base_pub(address _to, uint _value)
    safetranfer_token_pub(address _to, uint _value)
}


rule Check(address account) {
    env e;
    removeLiquidityForMember(e);

    assert balanceBaseOfThis() <= getBaseAmount();

}