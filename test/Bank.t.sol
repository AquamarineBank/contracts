pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "./BaseTest.sol";
import "contracts/Bank.sol";
import "contracts/1USD.sol";

contract BankTest is BaseTest {
    Bank bankContract; 
    OneUSD oneUSDContract;

    function setUp() public {
        deployOwners();
        deployCoins();    
        mintStables();

        bankContract = new Bank();
        oneUSDContract = OneUSD(bankContract._1USD());

        bankContract.addBacking(address(DAI));
        bankContract.addBacking(address(USDC));
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
}