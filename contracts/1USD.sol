// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import "contracts/interfaces/I1USD.sol";

contract OneUSD is I1USD {

    uint256 private _totalSupply;
    string constant internal _NAME = "One Aquamarine Dollar";
    string constant internal _SYMBOL = "1USD";
    string constant internal _VERSION = "1";
    uint8 constant internal _DECIMALS = 18;

    bool public paused;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    address public bank;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(address initialSupplyRecipient, uint initialAmount) {
        bank = msg.sender;
        _mint(initialSupplyRecipient, initialAmount);
    }


    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }

    // No checks as its meant to be once off to set minting rights to Bank.sol
    function setBank(address _bank) external {
        require(msg.sender == bank);
        bank = _bank;
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

    //Bank Functions
    function pauseMinting() external {
        require(msg.sender == bank);
        paused = true;
    }
    function resumeMinting() external {
        require(msg.sender == bank);
        paused = false;
    }

    function mint(address account, uint amount) external returns (bool) {
        require(msg.sender == bank);
        require(!paused);
        _mint(account, amount);
        return true;
    }
    function burn(address account, uint amount) external returns (bool) {
        require(msg.sender == bank);
        _burn(account, amount);
        return true;
    }

    //Internal Functions
    function _mint(address _to, uint _amount) internal returns (bool) {
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