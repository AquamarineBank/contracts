pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "solmate/test/utils/mocks/MockERC20.sol";
import "contracts/Bank.sol";
import "contracts/USD.sol";
import "contracts/AQUA.sol";
import "contracts/Boardroom.sol";
import "contracts/Briber.sol";
import "test/mocks/BribeMock.sol";

abstract contract BaseTest is Test {
    uint256 constant USDC_1 = 1e6;
    uint256 constant USDC_100K = 1e11; // 1e5 = 100K tokens with 6 decimals
    uint256 constant TOKEN_1 = 1e18;
    uint256 constant TOKEN_100K = 1e23; // 1e5 = 100K tokens with 18 decimals

    address[] owners;
    MockERC20 USDC;
    MockERC20 DAI;

    Bank bankContract; 
    OneUSD oneUSDContract;
    Boardroom boardroomContract;
    Aquamarine aqua;
    Briber briberContract;
    BribeMock bribeMockContract;

    function deployOwners() public {
        owners = new address[](3);
        owners[0] = address(this);
        owners[1] = address(0x2);
        owners[2] = address(0x3);
    }

    function deployCoins() public {
        USDC = new MockERC20("USDC", "USDC", 6);
        DAI = new MockERC20("DAI", "DAI", 18);
    }

    function mintStables() public {
        for (uint256 i = 0; i < owners.length; i++) {
            USDC.mint(owners[i], 1e12 * USDC_1);
            DAI.mint(owners[i], 1e12 * TOKEN_1);
        }
    }

    function deployUSD() public {
        aqua = new Aquamarine(address(this),100*TOKEN_1,3*TOKEN_100K);
        bankContract = new Bank();
        oneUSDContract = OneUSD(bankContract._USD());
        bribeMockContract = new BribeMock();
        briberContract = new Briber(address(bribeMockContract),address(this),address(aqua));
        aqua.setBriber(address(briberContract));

        address[] memory allowedRewards = new address[](1);
        allowedRewards[0] = address(oneUSDContract);

        boardroomContract = new Boardroom(address(aqua), address(oneUSDContract),allowedRewards,address(this));

        bankContract.addBacking(address(DAI));
        bankContract.addBacking(address(USDC));
        bankContract.setBoardroom(address(boardroomContract));
    }
}