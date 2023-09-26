// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "contracts/interfaces/IBribe.sol";
import "contracts/interfaces/IAqua.sol";

contract Briber is Ownable {
    uint internal constant WEEK = 86400 * 7; // allows minting and bribing once per week (reset every Thursday 00:00 UTC)
    uint public active_period;

    address public immutable AQUA;
    address public bribe;
    uint256 public bribeAmount = 2000 * 1e18;
    mapping(address => bool) public briberRole;

    event Bribed(address briber, address bribeDestination);
    event BriberAdded(address newBriber);
    event BriberRemoved(address oldBriber);
    event NewBribeDestination(address newBribeDest);
    event AquaMintingPaused(uint indexed timestamp);
    event AquaMintingResumed(uint indexed timestamp);

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
    
    function bribePool() public {
        require(block.timestamp >= active_period + WEEK, "already bribed this epoch");

        active_period = ((block.timestamp) / WEEK) * WEEK;

        IAqua(AQUA).mint(address(this), bribeAmount);
        IERC20(AQUA).approve(bribe, bribeAmount);
        IBribe(bribe).notifyRewardAmount(AQUA, bribeAmount);
        bribeAmount = bribeAmount - (bribeAmount / 1000);

        emit Bribed(msg.sender, bribe);
    }
    // Owner Functions
    function bribeSpecial(address _bribe, uint256 _amount) external {
        require(briberRole[msg.sender], "not a briber");
        require(_amount <= bribeAmount, "cant bribe > current bribeAmt");
        
        IAqua(AQUA).mint(address(this), _amount);
        IERC20(AQUA).approve(_bribe, _amount);
        IBribe(_bribe).notifyRewardAmount(
                AQUA,
                _amount
            );


        emit Bribed(msg.sender, _bribe);
    }
    function setBribeDestination(address _bribe) external onlyOwner {
        _removeAllowances();
        bribe = _bribe;
        _giveAllowances();

        emit NewBribeDestination(_bribe);
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

        emit AquaMintingPaused(block.timestamp);
    }
    function resumeMinting() public onlyOwner{
        IAqua(AQUA).resumeMinting();

        emit AquaMintingResumed(block.timestamp);
    }
    //Internal
    function _giveAllowances() internal {
        IERC20(AQUA).approve(bribe, type(uint256).max);
    }
    function _removeAllowances() internal {
        IERC20(AQUA).approve(bribe, 0);
    }
}
