pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "contracts/interfaces/I1USD.sol";
import "contracts/interfaces/IGauge.sol";
import "contracts/interfaces/IERC20.sol";
 

/**
 * @dev This contract allow users to deposit collateral and mint 1USD.
 * It also allows users to redeem 1USD for any of the underlying collateral.
 */
contract Bank is Ownable {
    mapping (address => bool) public backings;
    mapping (address => uint) public reserves;
    mapping (address => bool) public paused;

    address _1USD; 
    address staker;
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
        require (_gauge != address(0));
        staker = _gauge;
    }
    function addBacking(address _token) public onlyOwner {
        require (!backings[_token], "this is already a backing");
        backings[_token] = true;
    }
    function pauseMinting() public onlyOwner{
        I1USD(_1USD).pauseMinting();
    }
    function resumeMinting() public onlyOwner{
        I1USD(_1USD).resumeMinting();
    }


    // READ functions
    function balanceOf(address token) public returns (uint amount) { 
       amount = _to18decimals(token,IERC20Total(token).balanceOf(address(this)));
    }

    //precision functions
    function _to18decimals(address _token,uint _amount) internal returns (uint amount)  {
       amount = _amount * 1e18 / 10**IERC20Total(_token).decimals();
    }

    function _from18decimals(address _token,uint _amount) internal returns (uint amount,uint amount18decimals) {
       amount = _amount * 10**IERC20Total(_token).decimals() / 1e18;
       amount18decimals = _to18decimals(_token,amount); // to cover precision lost
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

        uint _amount = _to18decimals(token,amount);

        reserves[token] = reserves[token] + _amount;
        I1USD(_1USD).mint(msg.sender, _amount);

        if (balanceOf(token) > reserves[token]) {
            uint256 excess = balanceOf(token) - reserves[token];
            I1USD(_1USD).mint(address(this), excess);
            IGauge(staker).notifyRewardAmount(_1USD,excess);
        }
    }

    function redeem(address want, uint amount) public {
        require (amount > 0, "You cant reddem 0");
        require (reserves[want] >= amount, "There are not enough reserves");

        (uint _amount,uint _amount18decimals) = _from18decimals(want,amount);
        uint256 sendAmnt = _amount18decimals * redeemFee / 1000;

        I1USD(_1USD).burn(msg.sender, _amount18decimals); // dust that can not be converted to 6 digit tokens is left on user wallet

        (uint _sendAmnt,uint _sendAmnt18decimals) = _from18decimals(want,sendAmnt);
        uint256 feeAmnt = _amount18decimals - _sendAmnt18decimals;

        SafeERC20.safeTransferFrom(
            IERC20(want),
            address(this),
            _msgSender(),
            _sendAmnt
        );

        I1USD(_1USD).mint(address(this), feeAmnt);
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
        require(backings[_token] = false, "cant sweep backings");
        SafeERC20.safeTransfer(IERC20(_token), _to, _amount);
    }

}