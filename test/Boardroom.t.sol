pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "./BaseTest.sol";
import "./Bank.t.sol";
import "contracts/Bank.sol";
import "contracts/USD.sol";
import "contracts/AQUA.sol";
import "contracts/Boardroom.sol";

contract BoardroomTest is BaseTest {
    Bank bankContract; 
    OneUSD oneUSDContract;
    Boardroom boardroomContract;
    Aquamarine aqua;
    BankTest banktest;

    function setUp() public {
        deployOwners();
        deployCoins();    
        mintStables();

        aqua = new Aquamarine(address(this),100*TOKEN_1,3*TOKEN_100K);
        bankContract = new Bank();
        oneUSDContract = OneUSD(bankContract._USD());

        address[] memory allowedRewards = new address[](1);
        allowedRewards[0] = address(oneUSDContract);

        boardroomContract = new Boardroom(address(aqua), address(oneUSDContract),allowedRewards,address(this));

        bankContract.addBacking(address(DAI));
        bankContract.addBacking(address(USDC));
        bankContract.setBoardroom(address(boardroomContract));
    }

    function testStakeAqua() public {
        uint256 aquaBalBefore = aqua.balanceOf(address(owners[0]));

        aqua.approve(address(boardroomContract), TOKEN_1);
        boardroomContract.deposit(TOKEN_1);

        uint256 aquaBalAfter = aqua.balanceOf(address(owners[0]));
        uint depositBal = boardroomContract.balanceOf(address(owners[0]));

        assertEq(aquaBalBefore - aquaBalAfter, TOKEN_1);
        assertEq(depositBal, TOKEN_1);
        
    }

    function testStakeAquaAndWitdraw() public {
        uint256 aquaBalBefore = aqua.balanceOf(address(owners[0]));

        aqua.approve(address(boardroomContract), TOKEN_1);
        boardroomContract.deposit(TOKEN_1);

        uint256 aquaBalAfter = aqua.balanceOf(address(owners[0]));
        uint depositBal = boardroomContract.balanceOf(address(owners[0]));

        boardroomContract.withdraw(TOKEN_1);
        
        uint256 aquaBalAfterWithdraw = aqua.balanceOf(address(owners[0]));
        uint depositBalAfterWithdraw = boardroomContract.balanceOf(address(owners[0]));


        assertEq(aquaBalBefore - aquaBalAfter, TOKEN_1);
        assertEq(depositBal, TOKEN_1);
        assertEq(aquaBalBefore,aquaBalAfterWithdraw);
        assertEq(depositBalAfterWithdraw, 0);        
    }

    function testStakeAquaEarnClaim() public {        
        aqua.approve(address(boardroomContract), TOKEN_1);
        boardroomContract.deposit(TOKEN_1);

        testMint18DeciThenRedeem();

        uint256 rewardsSentToBoardroom = oneUSDContract.balanceOf(address(boardroomContract));

        vm.warp(604800);

        address[] memory rewards = new address[](1);
        rewards[0] = address(oneUSDContract);
        boardroomContract.getReward(address(owners[0]), rewards);

        uint256 oneUSDBalAfterGetReward = oneUSDContract.balanceOf(address(owners[0]));
        
        assertEq(oneUSDBalAfterGetReward, rewardsSentToBoardroom);
    }

    function testMint18DeciThenRedeem() public {
        DAI.approve(address(bankContract), TOKEN_1);
        bankContract.deposit(address(DAI), TOKEN_1);
        
        uint256 oneUsdBalanceBefore = oneUSDContract.balanceOf(address(owners[0]));
        uint256 oneUsdBalanceBeforeRewards = oneUSDContract.balanceOf(address(boardroomContract));
        uint256 DAIBalanceBefore = DAI.balanceOf(address(owners[0]));
        uint256 DAIBalanceBankBefore = DAI.balanceOf(address(bankContract));

        oneUSDContract.approve(address(bankContract), oneUsdBalanceBefore);
        bankContract.redeem(address(DAI), oneUsdBalanceBefore);

        uint256 DAIBalanceAfter = DAI.balanceOf(address(owners[0]));
        uint256 oneUsdBalancAfter = oneUSDContract.balanceOf(address(owners[0]));
        uint256 oneUsdBalanceAfterRewards = oneUSDContract.balanceOf(address(boardroomContract));
        uint256 DAIBalanceBankAfter = DAI.balanceOf(address(bankContract));

        assertEq(oneUsdBalanceBefore - oneUsdBalancAfter,TOKEN_1);
        assertEq(DAIBalanceAfter - DAIBalanceBefore,TOKEN_1 * bankContract.redeemFee() / 1000);
        assertEq(DAIBalanceBankBefore - DAIBalanceBankAfter,TOKEN_1 * bankContract.redeemFee() / 1000);
        assertEq(oneUsdBalanceAfterRewards - oneUsdBalanceBeforeRewards,TOKEN_1 - (TOKEN_1 * bankContract.redeemFee() / 1000));
    }

    
}