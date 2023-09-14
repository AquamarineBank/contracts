pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "solmate/test/utils/mocks/MockERC20.sol";

abstract contract BaseTest is Test {
    uint256 constant USDC_1 = 1e6;
    uint256 constant USDC_100K = 1e11; // 1e5 = 100K tokens with 6 decimals
    uint256 constant TOKEN_1 = 1e18;
    uint256 constant TOKEN_100K = 1e23; // 1e5 = 100K tokens with 18 decimals

    address[] owners;
    MockERC20 USDC;
    MockERC20 DAI;

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
}