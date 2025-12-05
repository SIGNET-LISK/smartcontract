// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/MinimalForwarder.sol";

/**
 * @title DeployForwarder
 * @dev Standalone script to deploy only the MinimalForwarder
 * Useful for deploying forwarder to different networks or upgrading independently
 */
contract DeployForwarder is Script {
    function run() external {
        vm.startBroadcast();

        MinimalForwarder forwarder = new MinimalForwarder();

        console2.log("============================================");
        console2.log(" MINIMAL FORWARDER DEPLOYED ");
        console2.log("============================================");
        console2.log("Forwarder deployed at:", address(forwarder));
        console2.log("Deployer address:     ", msg.sender);
        console2.log("Current block:        ", block.number);
        console2.log("============================================");

        vm.stopBroadcast();
    }
}
