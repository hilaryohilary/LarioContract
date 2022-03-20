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
contract BuyLarioToken {
  address payable owner;
  using SafeMath for uint256;
  bool presale = false;

  constructor() {
    owner = payable(msg.sender);
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier presaleOn {
    require(presale == true);
    _;
  }

  function startPresale() public view returns(bool) {
    return presale == true;
  }

  function endPresale() public view returns(bool) {
    return presale == false;
  }

}