pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @dev This contract allow users to deposit collateral and mint 1USD.
 * It also allows users to redeem 1USD for any of the underlying collateral.
 */
contract Bank is Ownable {
    mapping (address => bool) public backings;
    mapping (address => uint) public reserves;
    mapping (address => bool) public paused;

    address _1USD; 
    address gauge;
    uint redeemFee = 990;

    constructor(address _1usd) {
        _1USD = _1usd;
    }

    // OwnerFunctions
    function setRedeemFee(uint _fee) public onlyOwner {
        require( _fee <= 995, "fee can't be higher than 5%");
        redeemFee = _fee;
    }
    function pause(address token) public onlyOwner {
        require (backings[token] = true, "This token in not a valid backing");
        require (paused[token] = false, "This token is paused");
        paused[token] = true;
    }
    function unPause(address token) public onlyOwner {
        require (backings[token] = true, "This token in not a valid backing");
        require (paused[token] = true, "This token is not paused");
        paused[token] = false;
    }
    function setStaker(address _gauge) public onlyOwner {
        require (_gauge != 0);
        staker = _gauge;
    }

    // READ functions
    function balanceOf(address token) public returns (uint amount) {
        IERC20(token).balanceOf(address(this));
    }

    // USER Functions
    function deposit(address token, uint amount) public {
        require (amount > 0, "You cant deposit 0");
        require (backings[token] = true, "This token in not a valid deposit");
        require (paused[token] = false, "This token is paused");
        SafeERC20.safeTransferFrom(
            IERC20(token),
            _msgSender(),
            address(this),
            amount
        );
        reserves[token] = reserves[token] + amount;
        I1USD.mint(msg.sender, amount);

        if (balanceOf(token) > reserves[token]) {
            uint256 excess = balanceOf(token) - reserves[token];
            I1USD.mint(address(this), excess);
            IGauge(staker).notifyRewardAmount(excess);
        }
    }

    function redeem(address want, uint amount) public {
        require (amount > 0, "You cant reddem 0");
        require (reserves[want] >= amount, "There are not enough reserves");
        uint256 sendAmnt = amount * redeemFee / 1000;
        uint256 feeAmnt = amount - sendAmnt;

        I1USD.burn(msg.sender, amount);

        SafeERC20.safeTransferFrom(
            IERC20(want),
            address(this),
            _msgSender(),
            sendAmnt
        );
        I1USD.mint(address(this), feeAmnt);
        IGauge(staker).notifyRewardAmount(_1USD, feeAmnt);
    }


    /**
     * @dev Allows owner to clean out the contract of ANY tokens that are not backing.
     */
    function inCaseTokensGetStuck(
        address _token,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        require(backings[token] = false, "cant sweep backings");
        SafeERC20.safeTransfer(IERC20(_token), _to, _amount);
    }

}