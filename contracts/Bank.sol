pragma solidity 0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20Metadata.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "contracts/USD.sol";
import "contracts/interfaces/IUSD.sol";
import "contracts/interfaces/IGauge.sol";

/**
 * @dev This contract allow users to deposit collateral and mint USD.
 * It also allows users to redeem USD for any of the underlying collateral.
 */
contract Bank is Ownable {
    mapping (address => bool) public backings;
    mapping (address => uint) public reserves;
    mapping (address => bool) public paused;
    mapping (address => bool) public panicMen;

    event RedeemFeeSet(uint indexed timestamp, uint newFee);
    event tokenPaused(uint indexed timestamp, address pausedToken);
    event paniced(uint indexed timestamp, address panicMan, address panicedToken);
    event panicManAdded(address newPanicMan);


    address public _USD; 
    address boardroom;
    uint public redeemFee = 990; //set to 1000 for free redemptions, 999 for 0.1%0


    constructor() {
        _USD = address(new OneUSD());
    }

    // OwnerFunctions
    function setRedeemFee(uint _fee) public onlyOwner {
        require( _fee <= 990, "fee can't be higher than 1%");
        redeemFee = _fee;

        emit RedeemFeeSet(block.timestamp, _fee);
    }
    function pause(address token) public onlyOwner {
        require (backings[token], "This token in not a valid backing");
        require (!paused[token], "This token is paused");
        paused[token] = true;

        emit tokenPaused(block.timestamp, token);
    }
    function unPause(address token) public onlyOwner {
        require (backings[token], "This token in not a valid backing");
        require (paused[token], "This token is not paused");
        paused[token] = false;
    }
    function setBoardroom(address _gauge) public onlyOwner {
        require (_gauge != address(0));
        boardroom = _gauge;
    }
    function addBacking(address _token) public onlyOwner {
        require (!backings[_token], "this is already a backing");
        backings[_token] = true;
    }
    function pauseMinting() public onlyOwner{
        IUSD(_USD).pauseMinting();
    }
    function resumeMinting() public onlyOwner{
        IUSD(_USD).resumeMinting();
    }
    function setPanicMan(address _man, bool _tf) public onlyOwner {
        panicMen[_man] = _tf;

        emit panicManAdded(_man);
    }

    //Community function
    function panic(address token) public {
        require (panicMen[msg.sender], "You are not able to do this");
        require (backings[token], "This token in not a valid backing");
        require (!paused[token], "This token is paused");
        paused[token] = true;

        emit paniced(block.timestamp, msg.sender, token);
    }
    

    // READ functions
    function balanceOf(address token) public returns (uint amount) { 
       amount = _to18decimals(token,IERC20Metadata(token).balanceOf(address(this)));
    }

    //precision functions
    function _to18decimals(address _token,uint _amount) internal returns (uint amount)  {
       amount = _amount * 1e18 / 10**IERC20Metadata(_token).decimals();
    }

    function _from18decimals(address _token,uint _amount) internal returns (uint amount,uint amount18decimals) {
       amount = _amount * 10**IERC20Metadata(_token).decimals() / 1e18;
       amount18decimals = _to18decimals(_token,amount); // to cover precision lost
    }

    function _transferRewardToBoardroom() internal {
        uint256 rewardTokenCollectedAmount = IERC20(_USD).balanceOf(address(this));

        uint256 leftRewards = IGauge(boardroom).left(_USD);

        if(rewardTokenCollectedAmount > leftRewards) { // we are sending rewards only if we have more then the current rewards in the gauge
            SafeERC20.safeApprove(IERC20(_USD), boardroom, rewardTokenCollectedAmount);
            IGauge(boardroom).notifyRewardAmount(_USD, rewardTokenCollectedAmount);
        }
    }

    // USER Functions
    function deposit(address token, uint amount) public {
        require (amount > 0, "You cant deposit 0");
        require (backings[token], "This token in not a valid deposit");
        require (!paused[token], "This token is paused");
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            address(this),
            amount
        );

        uint _amount = _to18decimals(token,amount);

        reserves[token] = reserves[token] + _amount;
        IUSD(_USD).mint(msg.sender, _amount);

        if (balanceOf(token) > reserves[token]) {
            uint256 excess = balanceOf(token) - reserves[token];
            IUSD(_USD).mint(address(this), excess);
            _transferRewardToBoardroom();
        }
    }
        function depositFor(address _recipent, address token, uint amount) public {
        require (amount > 0, "You cant deposit 0");
        require (backings[token], "This token in not a valid deposit");
        require (!paused[token], "This token is paused");
        require (_recipent != address(0), "Do not mint to the burn address");
        SafeERC20.safeTransferFrom(
            IERC20(token),
            msg.sender,
            address(this),
            amount
        );

        uint _amount = _to18decimals(token,amount);

        reserves[token] = reserves[token] + _amount;
        IUSD(_USD).mint(_recipent, _amount);

        if (balanceOf(token) > reserves[token]) {
            uint256 excess = balanceOf(token) - reserves[token];
            IUSD(_USD).mint(address(this), excess);
            _transferRewardToBoardroom();
        }
    }

    function redeem(address want, uint amount) public {
        require (amount > 0, "You cant reddem 0");
        require (reserves[want] >= amount, "There are not enough reserves");

        (uint _amount,uint _amount18decimals) = _from18decimals(want,amount);
        uint256 sendAmnt = _amount18decimals * redeemFee / 1000;

        IUSD(_USD).burn(msg.sender, _amount18decimals); // dust that can not be converted to 6 digit tokens is left on user wallet

        (uint _sendAmnt,uint _sendAmnt18decimals) = _from18decimals(want,sendAmnt);
        uint256 feeAmnt = _amount18decimals - _sendAmnt18decimals;

        SafeERC20.safeTransfer(
            IERC20(want),
            msg.sender,
            _sendAmnt
        );

        IUSD(_USD).mint(address(this), feeAmnt);
        _transferRewardToBoardroom();
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