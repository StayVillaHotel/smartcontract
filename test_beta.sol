pragma solidity ^0.4.21;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
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
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }
  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  uint256 totalSupply_;
  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
}

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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract Configurable is Ownable {
  using SafeMath for uint256;
  uint256 preIcoStage1Limit = 300000;
  uint256 preIcoStage2Limit = 200000;
  uint256 preIcoStage3Limit = 100000;
  uint256 icoStage1Limit = 2500000;
  uint256 icoStage2Limit = 5000000;
  uint256 icoStage3Limit = 10000000;
  uint256 icoStage4Limit = 11900000;
  uint16 basePrice = 400;
  uint16 preIcoStage1Bonus = 200;
  uint16 preIcoStage2Bonus = 160;
  uint16 preIcoStage3Bonus = 120;
  uint16 icoStage1Bonus = 120;
  uint16 icoStage2Bonus = 80;
  uint16 icoStage3Bonus = 40;
  uint256 preIcoStage1Sold = 0;
  uint256 preIcoStage2Sold = 0;
  uint256 preIcoStage3Sold = 0;
  uint256 icoStage1Sold = 0;
  uint256 icoStage2Sold = 0;
  uint256 icoStage3Sold = 0;
  uint256 icoStage4Sold = 0;
  uint256 soldTokens = 0;
  uint256 bonuses = 0;
  uint256 preIcoStage1Start = 1525132800; // May 1 00:00
  uint256 preIcoStage1End = 1525391999; // May 3 23:59
  uint256 preIcoStage2End = 1526255999; // May 13 23:59
  uint256 preIcoStage3End = 1527897599; // June 1 23:59
  uint256 icoStage1End = 1528415999; // June 7 23:59
  uint256 icoStage2End = 1529020799; // June 14 23:59
  uint256 icoStage3End = 1529625599; // June 21 23:59
  uint256 icoStage4End = 1530403199; // June 30 23:59
  uint256 created = 100000000;
  uint256 hardCap = 30000000;
  uint256 softCap = 2000000;
  mapping(address => uint256) refundTokenBalances;
  mapping(address => uint256) refundBonusBalances;
  mapping(address => bool) whiteListed;
  address fund = 0x726515d49Ae8659b49b8bfB645621f25A56313ec;

  modifier whenSoftCapReached() {
    require(soldTokens >= softCap);
    _;
  }

  modifier whenSoftCapNotReached() {
    require(soldTokens < softCap);
    _;
  }

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

  function Staged() public {
    currentStage = Stages.noIco;
  }

  function tokensAmount(uint256 _wei) internal returns (uint256) {
    uint256 tokens = 0;
    uint256 stageWei;
    uint256 stageTokens;
    uint256 stageBonuses;
    bool multiStage = false;
    if (_wei < 0.1 ether) {
      return 0;
    }
    if (now < preIcoStage1Start || currentStage == Stages.IcoEnd) return 0;
    if (now <= preIcoStage1End && preIcoStage1Sold < preIcoStage1Limit) {
      currentStage = Stages.PreIcoStage1;
      if (_wei < 1 ether) {
        return 0;
      }
      if (!whiteListed[msg.sender]) {
        return 0;
      }
      stageWei = _wei;
      stageTokens = stageWei.mul(basePrice).div(1 ether);
      if (stageTokens <= preIcoStage1Limit.sub(preIcoStage1Sold)) {
        preIcoStage1Sold = preIcoStage1Sold.add(stageTokens);
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(preIcoStage1Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        fund.transfer(stageWei);
        return tokens;
      } else {
        stageTokens = preIcoStage1Limit.sub(preIcoStage1Sold);
        stageWei = stageTokens.mul(1 ether).div(basePrice);
        preIcoStage1Sold = preIcoStage1Limit;
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(preIcoStage1Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        _wei = _wei.sub(stageWei);
        multiStage = true;
        fund.transfer(stageWei);
      }
    }
    if (now > preIcoStage1End && preIcoStage1Limit > preIcoStage1Sold) {
      preIcoStage3Limit = preIcoStage3Limit.add(preIcoStage1Limit.sub(preIcoStage1Sold));
      preIcoStage1Limit = preIcoStage1Sold;
    }
    if (now <= preIcoStage2End && preIcoStage2Sold < preIcoStage2Limit) {
      currentStage = Stages.PreIcoStage2;
      if (_wei < 1 ether && !multiStage) {
        return 0;
      }
      if (!whiteListed[msg.sender]) {
        return 0;
      }
      stageWei = _wei;
      stageTokens = stageWei.mul(basePrice).div(1 ether);
      if (stageTokens <= preIcoStage2Limit.sub(preIcoStage2Sold)) {
        preIcoStage2Sold = preIcoStage2Sold.add(stageTokens);
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(preIcoStage2Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        fund.transfer(stageWei);
        return tokens;
      } else {
        stageTokens = preIcoStage2Limit.sub(preIcoStage2Sold);
        stageWei = stageTokens.mul(1 ether).div(basePrice);
        preIcoStage2Sold = preIcoStage2Limit;
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(preIcoStage2Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        _wei = _wei.sub(stageWei);
        multiStage = true;
        fund.transfer(stageWei);
      }
    }
    if (now > preIcoStage2End && preIcoStage2Limit > preIcoStage2Sold) {
      preIcoStage3Limit = preIcoStage3Limit.add(preIcoStage2Limit.sub(preIcoStage2Sold));
      preIcoStage2Limit = preIcoStage2Sold;
    }
    if (now <= preIcoStage3End && preIcoStage3Sold < preIcoStage3Limit) {
      currentStage = Stages.PreIcoStage3;
      if (_wei < 1 ether && !multiStage) {
        return 0;
      }
      if (!whiteListed[msg.sender]) {
        return 0;
      }
      stageWei = _wei;
      stageTokens = stageWei.mul(basePrice).div(1 ether);
      if (stageTokens <= preIcoStage3Limit.sub(preIcoStage3Sold)) {
        preIcoStage3Sold = preIcoStage3Sold.add(stageTokens);
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(preIcoStage3Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        fund.transfer(stageWei);
        return tokens;
      } else {
        stageTokens = preIcoStage3Limit.sub(preIcoStage3Sold);
        stageWei = stageTokens.mul(1 ether).div(basePrice);
        preIcoStage3Sold = preIcoStage3Limit;
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(preIcoStage3Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        _wei = _wei.sub(stageWei);
        msg.sender.transfer(_wei);
        fund.transfer(stageWei);
        return tokens;
      }
    }
    if (now > preIcoStage3End && preIcoStage3Limit > preIcoStage3Sold) {
      icoStage4Limit = icoStage4Limit.add(preIcoStage3Limit.sub(preIcoStage3Sold));
      preIcoStage3Limit = preIcoStage3Sold;
    }
    if (now > preIcoStage3End && now <= icoStage1End && icoStage1Sold < icoStage1Limit) {
      currentStage = Stages.IcoStage1;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      stageWei = _wei;
      stageTokens = stageWei.mul(basePrice).div(1 ether);
      if (stageTokens <= icoStage1Limit.sub(icoStage1Sold)) {
        icoStage1Sold = icoStage1Sold.add(stageTokens);
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(icoStage1Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
        return tokens;
      } else {
        stageTokens = icoStage1Limit.sub(icoStage1Sold);
        stageWei = stageTokens.mul(1 ether).div(basePrice);
        icoStage1Sold = icoStage1Limit;
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(icoStage1Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        _wei = _wei.sub(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
      }
    }
    if (now > icoStage1End && icoStage1Limit > icoStage1Sold) {
      icoStage4Limit = icoStage4Limit.add(icoStage1Limit.sub(icoStage1Sold));
      icoStage1Limit = icoStage1Sold;
    }
    if (now > preIcoStage3End && now <= icoStage2End && icoStage2Sold < icoStage2Limit) {
      currentStage = Stages.IcoStage2;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      stageWei = _wei;
      stageTokens = stageWei.mul(basePrice).div(1 ether);
      if (stageTokens <= icoStage2Limit.sub(icoStage2Sold)) {
        icoStage2Sold = icoStage2Sold.add(stageTokens);
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(icoStage2Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
        return tokens;
      } else {
        stageTokens = icoStage2Limit.sub(icoStage2Sold);
        stageWei = stageTokens.mul(1 ether).div(basePrice);
        icoStage2Sold = icoStage2Limit;
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(icoStage2Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        _wei = _wei.sub(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
      }
    }
    if (now > icoStage2End && icoStage2Limit > icoStage2Sold) {
      icoStage4Limit = icoStage4Limit.add(icoStage2Limit.sub(icoStage2Sold));
      icoStage2Limit = icoStage2Sold;
    }
    if (now > preIcoStage3End && now <= icoStage3End && icoStage3Sold < icoStage3Limit) {
      currentStage = Stages.IcoStage3;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      stageWei = _wei;
      stageTokens = stageWei.mul(basePrice).div(1 ether);
      if (stageTokens <= icoStage3Limit.sub(icoStage3Sold)) {
        icoStage3Sold = icoStage3Sold.add(stageTokens);
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(icoStage3Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
        return tokens;
      } else {
        stageTokens = icoStage3Limit.sub(icoStage3Sold);
        stageWei = stageTokens.mul(1 ether).div(basePrice);
        icoStage3Sold = icoStage3Limit;
        soldTokens = soldTokens.add(stageTokens);
        stageBonuses = stageWei.mul(icoStage3Bonus).div(1 ether);
        bonuses = bonuses.add(stageBonuses);
        tokens = tokens.add(stageTokens).add(stageBonuses);
        _wei = _wei.sub(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
      }
    }
    if (now > icoStage3End && icoStage3Limit > icoStage3Sold) {
      icoStage4Limit = icoStage4Limit.add(icoStage3Limit.sub(icoStage3Sold));
      icoStage3Limit = icoStage3Sold;
    }
    if (now > preIcoStage3End && now <= icoStage4End && icoStage4Sold < icoStage4Limit) {
      currentStage = Stages.IcoStage4;
      if (!whiteListed[msg.sender] && _wei > 10 ether) {
        return 0;
      }
      stageWei = _wei;
      stageTokens = stageWei.mul(basePrice).div(1 ether);
      if (stageTokens <= icoStage4Limit.sub(icoStage4Sold)) {
        icoStage4Sold = icoStage4Sold.add(stageTokens);
        soldTokens = soldTokens.add(stageTokens);
        tokens = tokens.add(stageTokens);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
        return tokens;
      } else {
        stageTokens = icoStage4Limit.sub(icoStage4Sold);
        stageWei = stageTokens.mul(1 ether).div(basePrice);
        icoStage4Sold = icoStage4Limit;
        soldTokens = soldTokens.add(stageTokens);
        tokens = tokens.add(stageTokens);
        _wei = _wei.sub(stageWei);
        refundTokenBalances[msg.sender] = refundTokenBalances[msg.sender].add(stageTokens);
        refundBonusBalances[msg.sender] = refundBonusBalances[msg.sender].add(stageBonuses);
        return tokens;
      }
    }
    return 0;
  }
}

contract RefundableToken is Staged, StandardToken {
  function refund() public whenSoftCapNotReached {
    if (now > icoStage4End || icoStage4Limit <= icoStage4Sold) {
      currentStage = Stages.IcoEnd;
    }
    require(currentStage == Stages.IcoEnd);
    require(refundTokenBalances[msg.sender] > 0);
    uint256 weiToRefund = refundTokenBalances[msg.sender].div(basePrice).mul(1 ether);
    uint256 tokenToRefund = refundTokenBalances[msg.sender].add(refundBonusBalances[msg.sender]);
    msg.sender.transfer(weiToRefund);
    totalSupply_ = totalSupply_.sub(tokenToRefund);
    balances[msg.sender] = balances[msg.sender].sub(tokenToRefund);
    refundTokenBalances[msg.sender] = 0;
    refundBonusBalances[msg.sender] = 0;
  }
}

contract BurnableToken is RefundableToken {
  bool public burned = false;

  modifier whenNotBurned() {
    require(!burned);
    _;
  }

  modifier whenBurned() {
    require(burned);
    _;
  }

  function burn() public onlyOwner whenNotBurned whenSoftCapReached {
    if (now > icoStage4End || icoStage4Limit <= icoStage4Sold) {
      currentStage = Stages.IcoEnd;
    }
    require(currentStage == Stages.IcoEnd);
    uint256 distributed = soldTokens.add(bonuses);
    uint256 tfb = distributed.mul(20).div(100);
    uint256 toBeBurned = balances[owner].sub(tfb);
    balances[owner] = balances[owner].sub(toBeBurned); // all remaining tokens
    totalSupply_ = totalSupply_.sub(toBeBurned);
    fund.transfer(address(this).balance);
    burned = true;
  }

  function setFund (address _address) public onlyOwner {
    fund = _address;
  }
}

contract PausableToken is Ownable, Configurable, BurnableToken {
  event Pause();
  event Unpause();

  bool public paused = false;


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
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused whenBurned public {
    paused = false;
    emit Unpause();
  }

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract CrowdsaleToken is PausableToken {
  function CrowdsaleToken() public {
    paused = true;
    balances[owner] = created;
    totalSupply_ = created;
  }
  
  function() public payable {
    uint256 tokens = tokensAmount(msg.value);
    require (tokens > 0);
    balances[owner] = balances[owner].sub(tokens);
    balances[msg.sender] = balances[msg.sender].add(tokens);
    emit Transfer(address(this), msg.sender, tokens);
  }

  function getSoldTokens() public view returns(uint256) {
    return soldTokens;
  }

  function getBonuses() public view returns(uint256) {
    return bonuses;
  }
}

contract StayToken is CrowdsaleToken {   
  string public constant name = "STAY Token";
  string public constant symbol = "STAY";
  uint32 public constant decimals = 10;
}