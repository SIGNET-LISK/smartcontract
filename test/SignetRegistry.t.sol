// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MinimalForwarder.sol";
import "../src/SignetRegistry.sol";

contract SignetRegistryTest is Test {

    MinimalForwarder forwarder;
    SignetRegistry registry;
    
    // Gunakan private key untuk signing
    uint256 ownerPrivateKey = 0x3e6cf5c4707bfdef30e4f6de49053303e081a2612fa1fecf75e74b2bab77eea7;
    uint256 publisherPrivateKey = 0x96b1a39d1022a0beaff9ef5ccdf6f38ad1cc4bf8bf232f6b761b4673f68586ec;
    uint256 relayerPrivateKey = 0x3e6cf5c4707bfdef30e4f6de49053303e081a2612fa1fecf75e74b2bab77eea8;
    
    address owner;
    address publisher;
    address relayer;

    function setUp() public {
        // Derive addresses from private keys
        owner = vm.addr(ownerPrivateKey);
        publisher = vm.addr(publisherPrivateKey);
        relayer = vm.addr(relayerPrivateKey);
        
        // Deploy forwarder first
        forwarder = new MinimalForwarder();
        
        // Deploy registry with forwarder address
        vm.startPrank(owner);
        registry = new SignetRegistry(address(forwarder));
        registry.addPublisher(publisher);
        vm.stopPrank();
        
        // Fund relayer for gas
        vm.deal(relayer, 10 ether);
    }

    function testAddPublisher() public view {
        assertTrue(registry.authorizedPublishers(publisher));
    }

    function testRegisterContentDirect() public {
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

    function testMetaTxRegisterContent() public {
        // Prepare the function call data
        bytes memory data = abi.encodeWithSelector(
            registry.registerContent.selector,
            "metahash1",
            "Meta Title",
            "Meta Description"
        );

        // Create forward request
        MinimalForwarder.ForwardRequest memory req = MinimalForwarder.ForwardRequest({
            from: publisher,
            to: address(registry),
            value: 0,
            gas: 1000000,
            nonce: forwarder.getNonce(publisher),
            data: data
        });

        // Sign the request as publisher using private key
        bytes32 digest = _getDigest(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(publisherPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Relayer executes the meta-transaction
        vm.prank(relayer);
        (bool success,) = forwarder.execute(req, signature);
        
        assertTrue(success);

        // Verify the content was registered with publisher as the sender
        (address p,,,) = registry.getContentData("metahash1");
        assertEq(p, publisher, "Publisher should be the actual user, not relayer");
    }

    function testMetaTxAddPublisher() public {
        address newPublisher = address(0xD1);
        
        // Prepare the function call data
        bytes memory data = abi.encodeWithSelector(
            registry.addPublisher.selector,
            newPublisher
        );

        // Create forward request from owner
        MinimalForwarder.ForwardRequest memory req = MinimalForwarder.ForwardRequest({
            from: owner,
            to: address(registry),
            value: 0,
            gas: 1000000,
            nonce: forwarder.getNonce(owner),
            data: data
        });

        // Sign the request as owner using private key
        bytes32 digest = _getDigest(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        // Relayer executes the meta-transaction
        vm.prank(relayer);
        (bool success,) = forwarder.execute(req, signature);
        
        assertTrue(success);
        assertTrue(registry.authorizedPublishers(newPublisher));
    }

    function testDirectCallStillWorks() public {
        // Ensure backward compatibility - direct calls still work
        vm.startPrank(publisher);
        registry.registerContent("directhash", "Direct Title", "Direct Desc");
        vm.stopPrank();

        (address p,,,) = registry.getContentData("directhash");
        assertEq(p, publisher);
    }

    function testForwarderCorrectlySetsPublisher() public {
        // This test ensures that when using forwarder, 
        // the publisher is Wallet B (actual user), not Wallet A (relayer)
        
        bytes memory data = abi.encodeWithSelector(
            registry.registerContent.selector,
            "testpublisher",
            "Test",
            "Test"
        );

        MinimalForwarder.ForwardRequest memory req = MinimalForwarder.ForwardRequest({
            from: publisher,
            to: address(registry),
            value: 0,
            gas: 1000000,
            nonce: forwarder.getNonce(publisher),
            data: data
        });

        bytes32 digest = _getDigest(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(publisherPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(relayer);
        forwarder.execute(req, signature);

        (address p,,,) = registry.getContentData("testpublisher");
        
        // Critical assertion: publisher should be the actual user (publisher)
        // NOT the relayer who paid for gas
        assertEq(p, publisher);
        assertTrue(p != relayer, "Publisher should NOT be the relayer");
    }

    function testNonceIncrement() public {
        uint256 initialNonce = forwarder.getNonce(publisher);
        
        bytes memory data = abi.encodeWithSelector(
            registry.registerContent.selector,
            "noncehash",
            "Nonce Test",
            "Testing nonce"
        );

        MinimalForwarder.ForwardRequest memory req = MinimalForwarder.ForwardRequest({
            from: publisher,
            to: address(registry),
            value: 0,
            gas: 1000000,
            nonce: initialNonce,
            data: data
        });

        bytes32 digest = _getDigest(req);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(publisherPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.prank(relayer);
        forwarder.execute(req, signature);

        assertEq(forwarder.getNonce(publisher), initialNonce + 1);
    }

    // Helper function to create EIP-712 digest
    function _getDigest(MinimalForwarder.ForwardRequest memory req) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)"),
                req.from,
                req.to,
                req.value,
                req.gas,
                req.nonce,
                keccak256(req.data)
            )
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("MinimalForwarder"),
                keccak256("1.0.0"),
                block.chainid,
                address(forwarder)
            )
        );

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
