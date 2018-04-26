pragma solidity ^0.4.23;
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function () public payable {
    revert();
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor () public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Configurable is Ownable {
  using SafeMath for uint256;
  uint256 preIcoStage1TotalWei = 500 ether;
  uint256 preIcoStage2TotalWei = 357.1528571429 ether;
  uint256 preIcoStage3TotalWei = 192.3076923077 ether;
  uint256 icoStage1TotalWei = 5769.2307692308 ether;
  uint256 icoStage2TotalWei = 10416.6666666667 ether;
  uint256 icoStage3TotalWei = 22727.2727272727 ether;
  uint256 icoStage4TotalWei = 28500 ether;
  uint16 preIcoStage1Price = 600;
  uint16 preIcoStage2Price = 560;
  uint16 preIcoStage3Price = 520;
  uint16 icoStage1Price = 520;
  uint16 icoStage2Price = 480;
  uint16 icoStage3Price = 440;
  uint16 icoStage4Price = 400;
  uint256 preIcoStage1Wei = 0;
  uint256 preIcoStage2Wei = 0;
  uint256 preIcoStage3Wei = 0;
  uint256 icoStage1Wei = 0;
  uint256 icoStage2Wei = 0;
  uint256 icoStage3Wei = 0;
  uint256 icoStage4Wei = 0;
  uint256 preIcoStage1Start = 1525132800; // May 1 00:00
  uint256 preIcoStage1End = 1525391999; // May 3 23:59
  uint256 preIcoStage2End = 1526255999; // May 13 23:59
  uint256 preIcoStage3End = 1527897599; // June 1 23:59
  uint256 icoStage1End = 1528415999; // June 7 23:59
  uint256 icoStage2End = 1529020799; // June 14 23:59
  uint256 icoStage3End = 1529625599; // June 21 23:59
  uint256 icoStage4End = 1530403199; // June 30 23:59
  uint256 hardCap = 30000000;
  uint256 softCap = 2000000;
  mapping(address => uint256) refundTokenBalances;
  mapping(address => uint256) refundWeiBalances;
  mapping(address => bool) whiteListed;

  function whiteList (address _address) public onlyOwner {
    whiteListed[_address] = true;
  }
  function removeFromWhiteList (address _address) public onlyOwner {
    whiteListed[_address] = false;
  }
  function isWhiteListed (address _address) public view returns (bool) {
    return whiteListed[_address];
  }
}

contract Staged is Configurable {
  using SafeMath for uint256;
  enum Stages {noIco, PreIcoStage1, PreIcoStage2, PreIcoStage3, PreIcoEnd, IcoStage1, IcoStage2, IcoStage3, IcoStage4, IcoEnd}
  Stages currentStage;

  constructor () public {
    currentStage = Stages.noIco;
  }

  function tokensAmount(uint256 _wei) internal returns (uint256) {
    uint256 tokens = 0;
    uint256 stageWei;
    uint256 stageTokens;
    bool multiStage = false;
    if (_wei < 0.1 ether) {
      return 0;
    }
    if (now < preIcoStage1Start || currentStage == Stages.IcoEnd) return 0;
    if (now <= preIcoStage1End && preIcoStage1Wei < preIcoStage1TotalWei) {
      currentStage = Stages.PreIcoStage1;
      if (_wei < 1 ether) {
        return 0;
      }
      if (!whiteListed[msg.sender]) {
        return 0;
      }
      if (_wei <= preIcoStage1TotalWei.sub(preIcoStage1Wei)) {
        stageWei = _wei;
        stageTokens = stageWei.mul(preIcoStage1Price).div(1 ether);
        preIcoStage1Wei = preIcoStage1Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        owner.transfer(stageWei);
        return tokens;
      } else {
        stageWei = preIcoStage1TotalWei.sub(preIcoStage1Wei);
        stageTokens = stageWei.mul(preIcoStage1Price).div(1 ether);
        preIcoStage1Wei = preIcoStage1TotalWei;
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        multiStage = true;
        owner.transfer(stageWei);
      }
    }
    if (now > preIcoStage1End && preIcoStage1TotalWei > preIcoStage1Wei) {
      preIcoStage3TotalWei = preIcoStage3TotalWei.add(preIcoStage1TotalWei.sub(preIcoStage1Wei));
      preIcoStage1TotalWei = preIcoStage1Wei;
    }
    if (now <= preIcoStage2End && preIcoStage2Wei < preIcoStage2TotalWei) {
      currentStage = Stages.PreIcoStage2;
      if (_wei < 1 ether && !multiStage) {
        return 0;
      }
      if (!whiteListed[msg.sender]) {
        return 0;
      }
      if (_wei <= preIcoStage2TotalWei.sub(preIcoStage2Wei)) {
        stageWei = _wei;
        stageTokens = stageWei.mul(preIcoStage2Price).div(1 ether);
        preIcoStage2Wei = preIcoStage2Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        owner.transfer(stageWei);
        return tokens;
      } else {
        stageWei = preIcoStage2TotalWei.sub(preIcoStage2Wei);
        stageTokens = stageWei.mul(preIcoStage2Price).div(1 ether);
        preIcoStage2Wei = preIcoStage2TotalWei;
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        multiStage = true;
        owner.transfer(stageWei);
      }
    }
    if (now > preIcoStage2End && preIcoStage2TotalWei > preIcoStage2Wei) {
      preIcoStage3TotalWei = preIcoStage3TotalWei.add(preIcoStage2TotalWei.sub(preIcoStage2Wei));
      preIcoStage2TotalWei = preIcoStage2Wei;
    }
    if (now <= preIcoStage3End && preIcoStage3Wei < preIcoStage3TotalWei) {
      currentStage = Stages.PreIcoStage3;
      if (_wei < 1 ether && !multiStage) {
        return 0;
      }
      if (!whiteListed[msg.sender]) {
        return 0;
      }
      if (_wei <= preIcoStage3TotalWei.sub(preIcoStage3Wei)) {
        stageWei = _wei;
        stageTokens = stageWei.mul(preIcoStage3Price).div(1 ether);
        preIcoStage3Wei = preIcoStage3Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        owner.transfer(stageWei);
        return tokens;
      } else {
        stageWei = preIcoStage3TotalWei.sub(preIcoStage3Wei);
        stageTokens = stageWei.mul(preIcoStage3Price).div(1 ether);
        preIcoStage3Wei = preIcoStage3TotalWei;
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        msg.sender.transfer(_wei);
        owner.transfer(stageWei);
        return tokens;
      }
    }
    if (now > preIcoStage3End && preIcoStage3TotalWei > preIcoStage3Wei) {
      icoStage4TotalWei = icoStage4TotalWei.add(preIcoStage3TotalWei.sub(preIcoStage3Wei));
      preIcoStage3TotalWei = preIcoStage3Wei;
    }
    if (now > preIcoStage3End && now <= icoStage1End && icoStage1Wei < icoStage1TotalWei) {
      currentStage = Stages.IcoStage1;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      if (_wei <= icoStage1TotalWei.sub(icoStage1Wei)) {
        stageWei = _wei;
        stageTokens = stageWei.mul(icoStage1Price).div(1 ether);
        icoStage1Wei = icoStage1Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        return tokens;
      } else {
        stageWei = icoStage1TotalWei.sub(icoStage1Wei);
        stageTokens = stageWei.mul(icoStage1Price).div(1 ether);
        icoStage1Wei = icoStage1Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        multiStage = true;
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
      }
    }
    if (now > icoStage1End && icoStage1TotalWei > icoStage1Wei) {
      icoStage4TotalWei = icoStage4TotalWei.add(icoStage1TotalWei.sub(icoStage1Wei));
      icoStage1TotalWei = icoStage1Wei;
    }
    if (now > preIcoStage3End && now <= icoStage2End && icoStage2Wei < icoStage2TotalWei) {
      currentStage = Stages.IcoStage2;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      if (_wei <= icoStage2TotalWei.sub(icoStage2Wei)) {
        stageWei = _wei;
        stageTokens = stageWei.mul(icoStage2Price).div(1 ether);
        icoStage2Wei = icoStage2Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        return tokens;
      } else {
        stageWei = icoStage2TotalWei.sub(icoStage2Wei);
        stageTokens = stageWei.mul(icoStage2Price).div(1 ether);
        icoStage2Wei = icoStage2Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        multiStage = true;
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
      }
    }
    if (now > icoStage2End && icoStage2TotalWei > icoStage2Wei) {
      icoStage4TotalWei = icoStage4TotalWei.add(icoStage2TotalWei.sub(icoStage2Wei));
      icoStage2TotalWei = icoStage2Wei;
    }
    if (now > preIcoStage3End && now <= icoStage3End && icoStage3Wei < icoStage3TotalWei) {
      currentStage = Stages.IcoStage3;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      if (_wei <= icoStage3TotalWei.sub(icoStage3Wei)) {
        stageWei = _wei;
        stageTokens = stageWei.mul(icoStage3Price).div(1 ether);
        icoStage3Wei = icoStage3Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        return tokens;
      } else {
        stageWei = icoStage3TotalWei.sub(icoStage3Wei);
        stageTokens = stageWei.mul(icoStage3Price).div(1 ether);
        icoStage3Wei = icoStage3Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        multiStage = true;
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
      }
    }
    if (now > icoStage3End && icoStage3TotalWei > icoStage3Wei) {
      icoStage4TotalWei = icoStage4TotalWei.add(icoStage3TotalWei.sub(icoStage3Wei));
      icoStage3TotalWei = icoStage3Wei;
    }
    if (now > preIcoStage3End && now <= icoStage4End && icoStage4Wei < icoStage4TotalWei) {
      currentStage = Stages.IcoStage4;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      if (_wei <= icoStage4TotalWei.sub(icoStage4Wei)) {
        stageWei = _wei;
        stageTokens = stageWei.mul(icoStage4Price).div(1 ether);
        icoStage4Wei = icoStage4Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        return tokens;
      } else {
        stageWei = icoStage4TotalWei.sub(icoStage4Wei);
        stageTokens = stageWei.mul(icoStage4Price).div(1 ether);
        icoStage4Wei = icoStage4Wei.add(stageWei);
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        msg.sender.transfer(_wei);
        currentStage = Stages.IcoEnd;
        refundWeiBalances[msg.sender] = refundWeiBalances[msg.sender].add(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        return tokens;
      }
    }
    return 0;
  }

  function getStage () public view returns (uint256) {
    return uint256(currentStage);
  }
}

contract RefundableToken is Staged, StandardToken {
  function refund () public {
    if (now > icoStage4End || icoStage4TotalWei <= icoStage4Wei) {
      currentStage = Stages.IcoEnd;
    }
    require(currentStage == Stages.IcoEnd);
    require(totalSupply < softCap);
    require(refundWeiBalances[msg.sender] > 0);
    require(refundTokenBalances[msg.sender] > 0);
    msg.sender.transfer(refundWeiBalances[msg.sender]);
    totalSupply = totalSupply.sub(refundTokenBalances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(refundTokenBalances[msg.sender]);
    refundWeiBalances[msg.sender] = 0;
    refundTokenBalances[msg.sender] = 0;
  }
}

contract BurnableToken is RefundableToken {
  bool public burned = false;

  modifier whenNotBurned() {
    require(!burned);
    _;
  }

  function burn () public onlyOwner whenNotBurned {
    require(totalSupply >= softCap);
    if (now > icoStage4End || icoStage4TotalWei <= icoStage4Wei) {
      currentStage = Stages.IcoEnd;
    }
    require(currentStage == Stages.IcoEnd);
    balances[owner] = totalSupply.mul(20).div(100); // all remaining tokens
    totalSupply = totalSupply.add(balances[owner]);
    owner.transfer(address(this).balance);
    burned = true;
  }
}

contract PausableToken is BurnableToken {
  event Pause();
  event Unpause();

  bool public paused = true;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    if (!burned) {
      burn();
    }
    paused = false;
    emit Unpause();
  }

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return transferFrom(_from, _to, _value);
  }
}

contract CrowdsaleToken is PausableToken {
  constructor () public {
    balances[owner] = hardCap;
  }
  
  function () public payable {
    uint256 tokens = tokensAmount(msg.value);
    require (tokens > 0);
    balances[owner] = balances[owner].sub(tokens);
    totalSupply = totalSupply.add(tokens);
    balances[msg.sender] = balances[msg.sender].add(tokens);
    emit Transfer(address(this), msg.sender, tokens);
  }
}

contract StayToken is CrowdsaleToken {   
  string public constant name = "STAY Token";
  string public constant symbol = "STAY";
  uint32 public constant decimals = 10;
}