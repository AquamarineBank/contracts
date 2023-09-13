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

        oneUSDContract = new OneUSD(address(this),TOKEN_1);
        bankContract = new Bank(address(oneUSDContract));
    }
    function test1() public {

    }
}