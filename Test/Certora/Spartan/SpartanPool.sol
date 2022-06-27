/*
The following system is based on a simplified version of the Trident bug that was found by the certora prover.
Here's a brief explanation about the original system and bug:
https://medium.com/certora/exploiting-an-invariant-break-how-we-found-a-pool-draining-bug-in-sushiswaps-trident-585bd98a4d4f 

*/

pragma solidity ^0.8.0;

/*
In constant-product pools liquidity providers (LPs) deposit two types of underlying tokens (Token0 and Token1) in exchange for LP tokens. 
They can later burn LP tokens to reclaim a proportional amount of Token0 and Token1.
Trident users can swap one underlying token for the other by transferring some tokens of one type to the pool and receiving some number of the other token.
To determine the exchange rate, the pool returns enough tokens to ensure that
(reserves0 ⋅ reserves1)ᵖʳᵉ =(reserves0 ⋅ reserves1)ᵖᵒˢᵗ
where reserves0 and reserves1 are the amount of token0, token1 the system holds. 

On first liquidity deposit the system transfers 1000 amount of LP to address 0 to ensure the pool cannot be emptied.  
*/

contract ERC20  {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;

    }
   
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
    }
}
contract ConstantProductPoolFixed is ERC20 {
    uint256 internal constant MINIMUM_LIQUIDTY = 1000;
    address public token0;
    address public token1;
    uint256 internal reserve0;
    uint256 internal reserve1;
    uint256 public kLast;

    uint256 locked;
    modifier lock() {
        require(locked == 1, "LOCKED");
        locked = 2;
        _;
        locked = 1;
    }

    constructor(address _token0, address _token1)  {
        require(token0 != address(0));
        require(token0 != token1);
        token0 = _token0;
        token1 = _token1;
        locked = 1;
    }

    function transfer(
        address to,
        address token,
        uint256 amount
    ) internal {
        bool success = ERC20(token).transferFrom(address(this), to, amount);
        require(success, "TRANSFER FAILED");
    }

    function _update(
        uint256 balance0,
        uint256 balance1
    ) internal {
        reserve0 = balance0;
        reserve1 = balance1;
    }

    function getReserve0() public view returns (uint256) {
        return reserve0;
    }

    function getReserve1() public view returns (uint256) {
        return reserve1;
    }

    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveAmountIn,
        uint256 reserveAmountOut
    ) internal pure returns (uint256 amountOut) {
        amountOut =
            (amountIn * reserveAmountOut) /
            (reserveAmountIn + amountIn);
    }

    function _getReserves()
        internal
        view
        returns (uint256 _reserve0, uint256 _reserve1)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function _getBalances()
        internal
        view
        returns (uint256 _balance0, uint256 _balance1)
    {
        _balance0 = ERC20(token0).balanceOf(address(this));
        _balance1 = ERC20(token1).balanceOf(address(this));
    }

    function addLiquidityForMember(address member) public returns(uint liquidityUnits){
        uint256 _actualInputBase = ERC20(token0).balanceOf(address(this))-reserve0;
        uint256 _actualInputToken = ERC20(token1).balanceOf(address(this)) - reserve1;
        liquidityUnits=  calcLiquidityUnits(_actualInputBase, reserve0, _actualInputToken,reserve1, totalSupply());
        reserve0+=_actualInputBase;
        reserve1+=_actualInputToken;
        _mint(member, liquidityUnits);
        return liquidityUnits;
    }
    
    function calcLiquidityUnits(uint b, uint B, uint t, uint T, uint P) public pure returns (uint units){
        if(P == 0){
            return b;
        } else {
            // units = ((P (t B + T b))/(2 T B)) * slipAdjustment
            // P * (part1 + part2) / (part3) * slipAdjustment
            uint part1 = t*(B);
            uint part2 = T*(b);
            uint part3 = T*(B)*(2);
            uint _units = (P*(part1+(part2)))/(part3);
            return _units;  
        }
    }
    function removeLiquidityForMember(address member) public returns (uint outputBase, uint outputToken) {
        uint units = balanceOf(member);
        outputBase = calcLiquidityShare(units, token0, address(this));
        outputToken = calcLiquidityShare(units,token1, address(this));
        reserve0-=outputBase;
        reserve1-=outputToken;
        _burn(address(this), units);
        ERC20(token0).transfer(member, outputBase);
        ERC20(token1).transfer(member, outputToken);
        return (outputBase, outputToken);
    }
    function calcLiquidityShare(uint units, address token, address pool) public view returns (uint share){
        // share = amount * part/total
        // address pool = getPool(token);
        uint amount = ERC20(token).balanceOf(pool);
        uint totalSupply = ERC20(pool).totalSupply();
        return(amount*(units))/(totalSupply);
    }
}