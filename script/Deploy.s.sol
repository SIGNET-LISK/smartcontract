// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/MinimalForwarder.sol";
import "../src/SignetRegistry.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast(); // gunakan private key dari .env

        // Deploy MinimalForwarder first
        MinimalForwarder forwarder = new MinimalForwarder();
        
        // Deploy SignetRegistry with forwarder address
        SignetRegistry registry = new SignetRegistry(address(forwarder));

        // Logging informasi deployment
        console2.log("============================================");
        console2.log(" SIGNET CONTRACTS DEPLOYED ");
        console2.log("============================================");
        console2.log("MinimalForwarder deployed at:", address(forwarder));
        console2.log("SignetRegistry deployed at:  ", address(registry));
        console2.log("Deployer address:           ", msg.sender);
        console2.log("Current block:              ", block.number);
        console2.log("============================================");
        console2.log("");
        console2.log("IMPORTANT: Save these addresses for backend/frontend integration!");
        console2.log("Forwarder Address: ", address(forwarder));
        console2.log("Registry Address:  ", address(registry));
        console2.log("============================================");

        vm.stopBroadcast();
    }
}
