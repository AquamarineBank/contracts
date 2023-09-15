pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "./BaseTest.sol";
import "contracts/Bank.sol";
import "contracts/1USD.sol";
import "contracts/AQUA.sol";
import "contracts/Boardroom.sol";

contract BankTest is BaseTest {
    Bank bankContract; 
    OneUSD oneUSDContract;
    Boardroom boardroomContract;
    Aquamarine aqua;

    function setUp() public {
        deployOwners();
        deployCoins();    
        mintStables();

        aqua = new Aquamarine(address(this),100*TOKEN_1,3*TOKEN_100K);
        bankContract = new Bank();
        oneUSDContract = OneUSD(bankContract._1USD());

        address[] memory allowedRewards = new address[](1);
        allowedRewards[0] = address(oneUSDContract);

        boardroomContract = new Boardroom(address(aqua), address(oneUSDContract),allowedRewards,address(this));

        bankContract.addBacking(address(DAI));
        bankContract.addBacking(address(USDC));
        bankContract.setBoardroom(address(boardroomContract));
    }

    function testMint18Decimals() public {
        uint256 daiBalanceBefore = DAI.balanceOf(address(owners[0]));
        uint256 oneUsdBalanceBefore = oneUSDContract.balanceOf(address(owners[0]));

        DAI.approve(address(bankContract), TOKEN_1);
        bankContract.deposit(address(DAI), TOKEN_1);

        uint256 daiBalanceAfter = DAI.balanceOf(address(owners[0]));
        uint256 oneUsdBalancAfter = oneUSDContract.balanceOf(address(owners[0]));

        assertEq(daiBalanceBefore - daiBalanceAfter, TOKEN_1);
        assertEq(oneUsdBalancAfter - oneUsdBalanceBefore, TOKEN_1);
    }

    function testMint6Decimals() public {
        uint256 usdcBalanceBefore = USDC.balanceOf(address(owners[0]));
        uint256 oneUsdBalanceBefore = oneUSDContract.balanceOf(address(owners[0]));

        USDC.approve(address(bankContract), USDC_1);
        bankContract.deposit(address(USDC), USDC_1);

        uint256 usdcBalanceAfter = USDC.balanceOf(address(owners[0]));
        uint256 oneUsdBalancAfter = oneUSDContract.balanceOf(address(owners[0]));

        assertEq(usdcBalanceBefore - usdcBalanceAfter, USDC_1);
        assertEq(oneUsdBalancAfter - oneUsdBalanceBefore, TOKEN_1);
    }

     function testMint6DeciThenRedeem() public {
        USDC.approve(address(bankContract), USDC_1);
        bankContract.deposit(address(USDC), USDC_1);
        
        uint256 oneUsdBalanceBefore = oneUSDContract.balanceOf(address(owners[0]));
        uint256 oneUsdBalanceBeforeRewards = oneUSDContract.balanceOf(address(boardroomContract));
        uint256 usdcBalanceBefore = USDC.balanceOf(address(owners[0]));
        uint256 usdcBalanceBankBefore = USDC.balanceOf(address(bankContract));

        oneUSDContract.approve(address(bankContract), oneUsdBalanceBefore);
        bankContract.redeem(address(USDC), oneUsdBalanceBefore);

        uint256 usdcBalanceAfter = USDC.balanceOf(address(owners[0]));
        uint256 oneUsdBalancAfter = oneUSDContract.balanceOf(address(owners[0]));
        uint256 oneUsdBalanceAfterRewards = oneUSDContract.balanceOf(address(boardroomContract));
        uint256 usdcBalanceBankAfter = USDC.balanceOf(address(bankContract));

        assertEq(oneUsdBalanceBefore - oneUsdBalancAfter,TOKEN_1);
        assertEq(usdcBalanceAfter - usdcBalanceBefore,USDC_1 * bankContract.redeemFee() / 1000);
        assertEq(usdcBalanceBankBefore - usdcBalanceBankAfter,USDC_1 * bankContract.redeemFee() / 1000);
        assertEq(oneUsdBalanceAfterRewards - oneUsdBalanceBeforeRewards,TOKEN_1 - (TOKEN_1 * bankContract.redeemFee() / 1000));
    }
}