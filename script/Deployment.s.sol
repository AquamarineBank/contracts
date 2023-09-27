// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

// Scripting tool
import {Script} from "../lib/forge-std/src/Script.sol";

import {Aquamarine} from "../contracts/AQUA.sol";
import {Bank} from "../contracts/Bank.sol";
import {OneUSD} from "../contracts/USD.sol";
import {Boardroom} from "../contracts/Boardroom.sol";
import {Briber} from "../contracts/Briber.sol";

contract Deployment is Script {

    //TODO
    address private constant TEAM_MULTI_SIG = address(0);

    //TODO Initial setings for mint
    uint256 mintCap = 300_000e18;
    uint256 initialMint = 4_000e18;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        Aquamarine aqua = new Aquamarine(TEAM_MULTI_SIG,initialMint,mintCap);

        Briber briberContract = new Briber(address(0),TEAM_MULTI_SIG,address(aqua));
        aqua.setBriber(address(briberContract)); 

        Bank bankContract = new Bank();
        OneUSD oneUSDContract = OneUSD(bankContract._USD());

        address[] memory allowedRewards = new address[](1);
        allowedRewards[0] = address(oneUSDContract);

        Boardroom boardroomContract = new Boardroom(address(aqua), address(oneUSDContract),allowedRewards,TEAM_MULTI_SIG);
        bankContract.setBoardroom(address(boardroomContract));

        bankContract.transferOwnership(TEAM_MULTI_SIG);

        vm.stopBroadcast();
    }
}