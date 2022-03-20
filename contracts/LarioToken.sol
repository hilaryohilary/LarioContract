// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title SafeMath
 */
library SafeMath {

    /**
    * Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface AltcoinToken {
    function balanceOf(address _owner) external returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
}

    contract LarioToken {
    
    using SafeMath for uint256;
    address payable owner;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => address) referrals;

    string public constant name = "LarioToken";
    string public constant symbol = "LTN";
    uint public constant decimals = 8;
    
    uint256 public totalSupply = 1e18;
    uint256 public totalDistributed = 0;        
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    event Burn(address indexed burner, uint256 value);
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    constructor () {
        owner = payable(msg.sender);
        // 5% dev fund,
        // 20% presale,
        // 15% promotion, airdrop and contest
        uint256 projectFund = totalSupply.mul(40).div(100);
        distr(owner, projectFund);
    }
    
    function transferOwnership(address payable newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    
    function distr(address _to, uint256 _amount) private returns (bool) {
        totalDistributed = totalDistributed.add(_amount);        
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);

        return true;
    }

    function balanceOf(address _owner) view public returns (uint256) {
        return balances[_owner];
    }

    // mitigates the BEP20 short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {
        
        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // mitigates the BEP20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) view public returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    function burn(uint256 _value) onlyOwner public {
        require(_value <= balances[msg.sender]);
        
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        totalDistributed = totalDistributed.sub(_value);
        emit Burn(burner, _value);
    }

    function withdraw() onlyOwner public {
        address myAddress = address(this);
        uint256 etherBalance = myAddress.balance;
        owner.transfer(etherBalance);
    }
    
    function withdrawAltcoinTokens(address _tokenContract) onlyOwner public returns (bool) {
        AltcoinToken token = AltcoinToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }

}
