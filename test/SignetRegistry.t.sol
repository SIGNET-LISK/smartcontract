// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/SignetRegistry.sol";

contract SignetRegistryTest is Test {

    SignetRegistry registry;
    address owner = address(0xA1);
    address publisher = address(0xB1);

    function setUp() public {
        vm.startPrank(owner);
        registry = new SignetRegistry();
        registry.addPublisher(publisher);
        vm.stopPrank();
    }

    function testAddPublisher() public view {
        assertTrue(registry.authorizedPublishers(publisher));
    }

    function testRegisterContent() public {
        vm.startPrank(publisher);
        registry.registerContent("hash123", "Test Content", "Testing Description");
        vm.stopPrank();

        (address p,,,) = registry.getContentData("hash123");
        assertEq(p, publisher);
    }

    function test_Revert_When_NotPublisher() public {
        vm.expectRevert();
        registry.registerContent("hashX", "Title", "Desc");
    }
}
