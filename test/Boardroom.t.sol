pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "./BaseTest.sol";
import "contracts/Bank.sol";
import "contracts/USD.sol";
import "contracts/AQUA.sol";
import "contracts/Boardroom.sol";

contract BoardroomTest is BaseTest {
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


    
}