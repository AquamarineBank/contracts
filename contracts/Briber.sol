// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "contracts/interfaces/IBribe.sol";
import "contracts/interfaces/IERC20.sol";

contract Briber is Ownable {
    address public AQUA;
    address public bribe;
    mapping(address => bool) public briberRole;

    event Bribed(address _briber);
    event BriberAdded(address newBriber);
    event BriberRemoved(address oldBriber);

    constructor(address _bribe, address _team) {
        bribe = _bribe;
        _giveAllowances();
        _transferOwnership(_team);
    }

    function balance() public view returns (uint) {
        return IERC20(AQUA).balanceOf(address(this));
    }
    // This function can be called repeatedly and the role must only be given to scheduled callers
    function bribe() public {
        require(briberRole[msg.sender] == true);
        uint256 _amount = balance() / 500;
        IBribe(bribe).notifyRewardAmount(
                AQUA,
                _amount
            );

        emit Bribed(msg.sender);
    }
    // Owner Functions
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
        SafeERC20.safeTransfer(IERC20(_token), _to, _amount);
    }
    //Internal
    function _giveAllowances() internal {
        IERC20(AQUA).approve(bribe, type(uint256).max);
    }
    function _removeAllowances() internal {
        IERC20(AQUA).approve(bribe, 0);
    }
}
