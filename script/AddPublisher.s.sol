// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/SignetRegistry.sol";

contract AddPublisher is Script {

    address registryAddress = 0x0000000000000000000000000000000000000000; // ganti setelah deploy
    address publisherWallet = 0x0000000000000000000000000000000000000000; // ganti pake real wallet

    function run() external {
        vm.startBroadcast();

        SignetRegistry registry = SignetRegistry(registryAddress);
        registry.addPublisher(publisherWallet);

        vm.stopBroadcast();
    }
}