// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "contracts/interfaces/IBribe.sol";
import "contracts/interfaces/IAqua.sol";

contract Briber is Ownable {
    uint internal constant WEEK = 86400 * 7; // allows minting and bribing once per week (reset every Thursday 00:00 UTC)
    uint public active_period;
    uint public last_bribe_pecial_period;

    address public AQUA;
    address public bribe;
    uint256 public bribeAmount = 2000 * 1e18;
    mapping(address => bool) public briberRole;

    event Bribed(address briber);
    event BriberAdded(address newBriber);
    event BriberRemoved(address oldBriber);

    constructor(address _bribe, address _team,address _aqua) {
        bribe = _bribe;
        AQUA = _aqua;
        _giveAllowances();
        _transferOwnership(_team);

         // allow to mint new emissions and bribe THIS Thursday
        active_period = ((block.timestamp) / WEEK) * WEEK;
    }

    function balance() public view returns (uint) {
        return IERC20(AQUA).balanceOf(address(this));
    }
    // This function can be called repeatedly and the role must only be given to scheduled callers
    function bribePool() public {
        require(briberRole[msg.sender], "not a briber");
        require(block.timestamp >= active_period + WEEK, "already bribed this epoch");

        active_period = ((block.timestamp) / WEEK) * WEEK;

        IAqua(AQUA).mint(address(this), bribeAmount);
        IERC20(AQUA).approve(bribe, bribeAmount);
        IBribe(bribe).notifyRewardAmount(AQUA, bribeAmount);
        bribeAmount = bribeAmount - (bribeAmount / 1000);

        emit Bribed(msg.sender);
    }
    // Owner Functions
    function bribeSpecial(address _bribe, uint256 _amount) external onlyOwner {
        require(_amount <= bribeAmount, "cant bribe > current bribeAmt");
        require(last_bribe_pecial_period < active_period, "last_bribe_pecial_period < active_period");
        
        last_bribe_pecial_period = active_period;
        IAqua(AQUA).mint(address(this), _amount);
        IERC20(AQUA).approve(_bribe, _amount);
        IBribe(bribe).notifyRewardAmount(
                AQUA,
                _amount
            );


        emit Bribed(msg.sender);
    }
    function setBribe(address _bribe) external onlyOwner {
        _removeAllowances();
        bribe = _bribe;
        _giveAllowances();
    }
    function addBriber(address _newBriber) external onlyOwner {
        briberRole[_newBriber] = true;

        emit BriberAdded(_newBriber);
    }
    function removeBriber(address _oldBriber) external onlyOwner {
        briberRole[_oldBriber] = false;

        emit BriberRemoved(_oldBriber);
    }
    function inCaseTokensGetStuck(
        address _token,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        require(_token != AQUA, "cant sweep AQUA");
        IERC20(_token).transfer(_to, _amount);
    }
    function pauseMinting() public onlyOwner{
        IAqua(AQUA).pauseMinting();
    }
    function resumeMinting() public onlyOwner{
        IAqua(AQUA).resumeMinting();
    }
    //Internal
    function _giveAllowances() internal {
        IERC20(AQUA).approve(bribe, type(uint256).max);
    }
    function _removeAllowances() internal {
        IERC20(AQUA).approve(bribe, 0);
    }
}
