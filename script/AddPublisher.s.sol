// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Script.sol";
import "../src/SignetRegistry.sol";

/**
 * @title AddPublisher
 * @dev Script to add a publisher to the SignetRegistry
 * 
 * NOTE: This can be called directly by the owner (pays gas)
 * OR through the MinimalForwarder for gasless execution
 */
contract AddPublisher is Script {

    address registryAddress = 0x7e2569669d07d01523eAdfC06994b9ad39Bc7475; // ganti setelah deploy
    address publisherWallet = 0xDA7d7Dad11720eB8b4EbC99f54f4D1073295Eb5B; // ganti pake real wallet

    function run() external {
        vm.startBroadcast();

        SignetRegistry registry = SignetRegistry(registryAddress);
        registry.addPublisher(publisherWallet);

        console2.log("Publisher added:", publisherWallet);

        vm.stopBroadcast();
    }
}