// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/SignetRegistry.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast(); // gunakan private key dari .env

        // Deploy contract
        SignetRegistry registry = new SignetRegistry();

        // Logging informasi deployment
        console2.log("============================================");
        console2.log(" SIGNET REGISTRY SMART CONTRACT DEPLOYED ");
        console2.log("============================================");
        console2.log("Contract deployed at:", address(registry));
        console2.log("Deployer address:", msg.sender);
        console2.log("Current block:", block.number);
        console2.log("============================================");

        vm.stopBroadcast();
    }
}
