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

    function setUp() public {
        deployOwners();
        deployCoins();    
        mintStables();
        deployUSD();
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

        address[] memory rewards = new address[](1);
        rewards[0] = address(oneUSDContract);

        assertEq(boardroomContract.left(address(oneUSDContract)),0);

        testMint18DeciThenRedeem();

        uint256 rewardsSentToBoardroom = boardroomContract.left(address(oneUSDContract));

        vm.warp(block.timestamp + 604800);
           
        boardroomContract.getReward(address(owners[0]), rewards);

        uint256 oneUSDBalAfterGetReward = oneUSDContract.balanceOf(address(owners[0]));
        
        assertEq(oneUSDBalAfterGetReward, rewardsSentToBoardroom);
    }

    function testMint18DeciThenRedeem() public {
        uint256 amoutToDepositRedem = TOKEN_1 *10;
        DAI.approve(address(bankContract), amoutToDepositRedem);
        bankContract.deposit(address(DAI), amoutToDepositRedem);
        
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

        assertEq(oneUsdBalanceBefore - oneUsdBalancAfter,amoutToDepositRedem);
        assertEq(DAIBalanceAfter - DAIBalanceBefore,amoutToDepositRedem * bankContract.redeemFee() / 1000);
        assertEq(DAIBalanceBankBefore - DAIBalanceBankAfter,amoutToDepositRedem * bankContract.redeemFee() / 1000);
        assertEq(oneUsdBalanceAfterRewards - oneUsdBalanceBeforeRewards,amoutToDepositRedem - (amoutToDepositRedem * bankContract.redeemFee() / 1000));
    }

    
}