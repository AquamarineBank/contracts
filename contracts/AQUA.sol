// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import "contracts/interfaces/IAqua.sol";

contract Aquamarine is IAqua {

    uint256 private _totalSupply;
    uint256 private immutable _cap;
    string constant internal _NAME = "Aquamarine Token";
    string constant internal _SYMBOL = "AQUA";
    string constant internal _VERSION = "1";
    uint8 constant internal _DECIMALS = 18;

    bool public paused;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    address public briber;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(address initialSupplyRecipient, uint initialAmount,uint256 cap) {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
        briber = msg.sender;
        _mint(initialSupplyRecipient, initialAmount);
    }


    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function cap() public view returns (uint256) {
        return _cap;
    }

    // No checks as its meant to be once off to set minting rights to briber.sol
    function setbriber(address _briber) external {
        require(msg.sender == briber);
        briber = _briber;
    }

    function approve(address _spender, uint _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint _value) external returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool) {
        uint allowed_from = allowance[_from][msg.sender];
        if (allowed_from != type(uint).max) {
            allowance[_from][msg.sender] -= _value;
        }
        return _transfer(_from, _to, _value);
    }

    //briber Functions
    function pauseMinting() external {
        require(msg.sender == briber);
        paused = true;
    }
    function resumeMinting() external {
        require(msg.sender == briber);
        paused = false;
    }

    function mint(address account, uint amount) external returns (bool) {
        require(msg.sender == briber);
        require(!paused);
        _mint(account, amount);
        return true;
    }
    function burn(address account, uint amount) external returns (bool) {
        require(msg.sender == briber);
        _burn(account, amount);
        return true;
    }

    //Internal Functions
    function _mint(address _to, uint _amount) internal returns (bool) {
        require(totalSupply() + _amount <= cap(), "ERC20Capped: cap exceeded");
        _totalSupply += _amount;
        unchecked {
            balanceOf[_to] += _amount;
        }
        emit Transfer(address(0x0), _to, _amount);
        return true;
    }
    function _burn(address _from, uint _amount) internal returns (bool) {
        _totalSupply -= _amount;
        unchecked {
            balanceOf[_from] -= _amount;
        }
        emit Transfer(_from, address(0x0), _amount);
        return true;
    }
    function _transfer(address _from, address _to, uint _value) internal returns (bool) {
        balanceOf[_from] -= _value;
        unchecked {
            balanceOf[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }


}