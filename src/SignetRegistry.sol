// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract SignetRegistry is Ownable {
    
    struct Content {
        address publisher;
        string title;
        string description;
        uint256 timestamp;
    }
    
    mapping(string => Content) public contentRegistry;
    mapping(address => bool) public authorizedPublishers;
    string[] public allHashes;

    event PublisherAdded(address indexed clientAddress);
    event ContentRegisteredFull(
        string indexed pHash,
        address indexed publisher,
        string title,
        string description,
        uint256 timestamp
    );

    constructor() Ownable(msg.sender) {}

    modifier onlyPublisher() {
        require(authorizedPublishers[msg.sender] == true, "SIGNET: Not an authorized publisher.");
        _;
    }

    function addPublisher(address _clientWallet) external onlyOwner {
        require(_clientWallet != address(0), "SIGNET: Invalid address.");
        require(!authorizedPublishers[_clientWallet], "SIGNET: Client already registered.");

        authorizedPublishers[_clientWallet] = true;
        emit PublisherAdded(_clientWallet); 
    }

    function registerContent(
        string memory _pHash, 
        string memory _title, 
        string memory _desc
    ) external onlyPublisher {
        
        require(bytes(_pHash).length > 0, "SIGNET: Hash cannot be empty.");
        require(contentRegistry[_pHash].publisher == address(0), "SIGNET: Hash already registered."); 

        contentRegistry[_pHash] = Content({
            publisher: msg.sender,
            title: _title,
            description: _desc,
            timestamp: block.timestamp
        });

        allHashes.push(_pHash);

        emit ContentRegisteredFull(
            _pHash,
            msg.sender,
            _title,
            _desc,
            block.timestamp
        );
    }

    function getAllHashes() public view returns (string[] memory) {
        return allHashes;
    }

    function getContentData(string memory _pHash) 
        public 
        view 
        returns (address, string memory, string memory, uint256) 
    {
        Content storage content = contentRegistry[_pHash];
        require(content.publisher != address(0), "SIGNET: Content not found.");

        return (
            content.publisher,
            content.title,
            content.description,
            content.timestamp
        );
    }
}
