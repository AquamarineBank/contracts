pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import "./BaseTest.sol";
import "contracts/Bank.sol";
import "contracts/USD.sol";
import "contracts/AQUA.sol";
import "contracts/Boardroom.sol";

contract BriberTest is BaseTest {

    function setUp() public {
        deployOwners();
        deployCoins();    
        mintStables();
        deployUSD();
    }

    function testBribePool() public {
        uint256 aquaPreMinted = aqua.totalSupply();

        briberContract.addBriber(address(this));
        vm.warp(block.timestamp + 7 days);
        briberContract.bribePool();
        assertEq(aqua.totalSupply() - aquaPreMinted,aqua.balanceOf(address(bribeMockContract)));

        vm.warp(block.timestamp + 7 days);
        briberContract.bribePool();
        
        assertEq(aqua.totalSupply() - aquaPreMinted,aqua.balanceOf(address(bribeMockContract)));
    }

    function testBribePoolInTheSamEpoch() public {
        uint256 aquaPreMinted = aqua.totalSupply();

        briberContract.addBriber(address(this));
        vm.warp(block.timestamp + 7 days);
        briberContract.bribePool();
        assertEq(aqua.totalSupply() - aquaPreMinted,aqua.balanceOf(address(bribeMockContract)));

        vm.expectRevert("already bribed this epoch");
        briberContract.bribePool();
        
    }

     function testBribeSpecial() public {
        uint256 aquaPreMinted = aqua.totalSupply();
        BribeMock bribeMockContract2 = new BribeMock();

        briberContract.addBriber(address(this));
        vm.warp(block.timestamp + 7 days);
        briberContract.bribePool();

        uint256 beforeBribe = aqua.balanceOf(address(bribeMockContract2));
        briberContract.bribeSpecial(address(bribeMockContract2), 1000 * 1e18);
        uint256 afterBribe = aqua.balanceOf(address(bribeMockContract2));
        assertEq(afterBribe - beforeBribe,1000 * 1e18);

        vm.warp(block.timestamp + 7 days);
        briberContract.bribePool();
        
        beforeBribe = aqua.balanceOf(address(bribeMockContract2));
        briberContract.bribeSpecial(address(bribeMockContract2), 1000 * 1e18);
        afterBribe = aqua.balanceOf(address(bribeMockContract2));
        assertEq(afterBribe - beforeBribe,1000 * 1e18);
    }

    function testBribePoolPauseMinting() public {
        uint256 aquaPreMinted = aqua.totalSupply();

        briberContract.addBriber(address(this));
        vm.warp(block.timestamp + 7 days);
        
        briberContract.pauseMinting();

        vm.expectRevert("mint paused");
        briberContract.bribePool();
        assertEq(aqua.totalSupply() - aquaPreMinted,aqua.balanceOf(address(bribeMockContract)));

    }

}