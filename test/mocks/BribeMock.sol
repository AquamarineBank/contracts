// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

import "contracts/interfaces/IBribe.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

contract BribeMock is IBribe {
    function _deposit(uint amount, uint tokenId) external {

    }

    function _withdraw(uint amount, uint tokenId) external {

    }

    function getRewardForOwner(uint tokenId, address[] memory tokens) external {

    }

    function notifyRewardAmount(address token, uint amount) external {
        _safeTransferFrom(token, msg.sender, address(this), amount);
    }

    function left(address token) external view returns (uint) {

    }

    function _safeTransferFrom(address token, address from, address to, uint256 value) internal {
        require(token.code.length > 0);
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
}