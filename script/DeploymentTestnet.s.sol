// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// Scripting tool
import {Script} from "../lib/forge-std/src/Script.sol";

import {Aquamarine} from "../contracts/AQUA.sol";
import {Bank} from "../contracts/Bank.sol";
import {OneUSD} from "../contracts/USD.sol";
import {Boardroom} from "../contracts/Boardroom.sol";
import {Briber} from "../contracts/Briber.sol";

import {TestERC20} from "../test/mocks/TestERC20.sol";
import {BribeMock} from "../test/mocks/BribeMock.sol";

contract DeploymentTestnet is Script { // To be executed only on testnet use for mock setup etc 

    //TODO
    address private constant DEPLOYER = address(0);

    address private constant BankAddress = address(0);
    address private constant BriberAdress = address(0);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        TestERC20 testUSD18 = new TestERC20("TestUSD18", "TestUSD18", 18);
        TestERC20 testUSD6 = new TestERC20("TestUSD6", "TestUSD6", 6);

        testUSD18.mint(DEPLOYER, 10_000_000e18);
        testUSD6.mint(DEPLOYER, 10_000_000e6);

        BribeMock bribeMockContract = new BribeMock();
       
        Briber briberContract = Briber(BriberAdress);
        briberContract.setBribeDestination(address(bribeMockContract));

        Bank bankContract = Bank(BankAddress);
        bankContract.addBacking(address(testUSD18));
        bankContract.addBacking(address(testUSD6));

        vm.stopBroadcast();
    }
}