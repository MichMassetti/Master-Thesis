// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}


contract BecTokenSimplified {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping(address => uint256) balances;

    constructor() {
        totalSupply = 7000000000 * (10**18);
        balances[msg.sender] = totalSupply; // Give the creator all initial tokens
    }
    
    function balanceOf(
        address _owner)
        public
        view
        returns (uint256)
    {
        return balances[_owner];
    }

    
    function transferFrom (address _from, address _to, uint _value) public {
        uint256 pre = balances[_from].add(balances[_to]);
        uint256 _balancesFrom = balances[_from];
        uint256 _balancesTo = balances[_to];

        uint256 _balancesFromNew = _balancesFrom.sub(_value);
        balances[_from] = _balancesFromNew;

        uint256 _balancesToNew = _balancesTo.add(_value);
        balances[_to] = _balancesToNew;
        uint256 post = balances[_from].add(balances[_to]);


    }
}


