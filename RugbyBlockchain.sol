// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

// import the OpenZeppelin ERC721 contract (NFT)
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";

//===============================================
//  Written by Samuel Gwlanold Edoumou. Paris
//  Paris, September 4, 2021
//===============================================

contract RugbyBlockchain is ERC721("Set In Stone", "SIS") {
    // structure that defines a user
    struct User {
        uint256 cardID;
        address userAddress;
        string CardstrID;
        string connectionDataHash;
    }
    
    // structure that defines a card
    struct Card {
        string ID;
        address cardOwner;
        string club;
        string position;
        string lastname;
        string firstname;
        string scarcity;
        uint256 season;
        uint256 strength;
        uint256 endurence;
        uint256 speed;
        uint256 level;
    }
    
    mapping(address => User) private users;
    mapping(string => address) public cardOwners;
    mapping(string => Card) private cards;
    
    uint256 public counter;
    
    address payable depositAddress;
    
    // this function secures the access to the user wallet (portefeuille)
    // by creating a blockchain-based-authentication
    function register(string memory _dataHash) public {
        // require that the user has not been registered yet
        require(
            users[msg.sender].userAddress == address(0x0000000000000000000000000000000000000000),
            "wallet alraedy created"
        );
        
        users[msg.sender].connectionDataHash = _dataHash;
        users[msg.sender].userAddress = msg.sender;
    }
    
    // get the user connection data Hash
    function getConnectionDataHash() public view returns(string memory) {
        // require the caller to have registered before (to have secured their wallet before)
        require(msg.sender == users[msg.sender].userAddress, "Not allowed");
        
        return users[msg.sender].connectionDataHash;
    }
    
    // Mints NFT cards
    // this function requires the caller to have been registered before calling (have secures the wallet before)
    function mintCard(
        string memory _cardID,
        string memory _club,
        string memory _position,
        string memory _lastname,
        string memory _firstname,
        string memory _scarcity,
        uint256 _season,
        uint256 _strength,
        uint256 _endurence,
        uint256 _speed,
        uint256 _level
    )
        public payable
    {
        // require the caller to have registered before (to have secured their wallet before)
        require(msg.sender == users[msg.sender].userAddress, "Not allowed");
        
        uint256 newCardID = counter;
        
        // mints the cards
        _safeMint(msg.sender, newCardID);
        
        // store the card ID in a mapping
        users[msg.sender].cardID = newCardID;
        users[msg.sender].CardstrID = _cardID;
        
        // transfer the ownership of the image to the minter
        cardOwners[_cardID] = ownerOf(newCardID);
        
        //== sets the card properties
        cards[_cardID].ID = _cardID;
        cards[_cardID].cardOwner = msg.sender;
        cards[_cardID].club = _club;
        cards[_cardID].position = _position;
        cards[_cardID].lastname = _lastname;
        cards[_cardID].firstname = _firstname;
        cards[_cardID].scarcity = _scarcity;
        cards[_cardID].season = _season;
        cards[_cardID].strength = _strength;
        cards[_cardID].endurence = _endurence;
        cards[_cardID].speed = _speed;
        cards[_cardID].level = _level;
        
        // Opening a card costs 0.05 ETH
        (bool success, ) = depositAddress.call{value: msg.value}("");
        require(success);
        
        counter++;
    }
    
    // approve the ERC721 token transfer
    function approveCardTransfer(address _to) public {
        // require the user to have an non-empty card
        require(
            keccak256(bytes(users[msg.sender].CardstrID)) != keccak256(bytes("")),
            "no card found for the caller"
        );
        
        approve(_to, users[msg.sender].cardID);
    }
    
    // Card exchange between users
    function cardExchange(address _secondUser) public {
        // require the users to have an non-empty card
        require(
            keccak256(bytes(users[msg.sender].CardstrID)) != keccak256(bytes("")),
            "no card found for the caller"
        );
        require(
            keccak256(bytes(users[_secondUser].CardstrID)) != keccak256(bytes("")),
            "no card found for the approved user"
        );
        
        safeTransferFrom(
            msg.sender,
            _secondUser,
            users[msg.sender].cardID,
            "Enjoy!"
        );
        
        safeTransferFrom(
            _secondUser,
            msg.sender,
            users[_secondUser].cardID,
            "Enjoy!"
        );
    }
    
    // generates
    function openBooster(
        string memory _cardID,
        string memory _club,
        string memory _position,
        string memory _lastname,
        string memory _firstname,
        uint256 _season,
        uint256 _strength,
        uint256 _endurence,
        uint256 _speed,
        uint256 _level,
        uint256[] memory _initialTab
    ) 
        public payable returns (uint256) 
    {
        // all requires must be set here
        require(msg.value >= 50000000000000000, "Not enough ETH");  // opening a booster costs 0.05 ETH
        
        //== sets the card properties
        cards[_cardID].ID = _cardID;
        cards[_cardID].cardOwner = msg.sender;
        cards[_cardID].club = _club;
        cards[_cardID].position = _position;
        cards[_cardID].lastname = _lastname;
        cards[_cardID].firstname = _firstname;
        cards[_cardID].season = _season;
        cards[_cardID].strength = _strength;
        cards[_cardID].endurence = _endurence;
        cards[_cardID].speed = _speed;
        cards[_cardID].level = _level;

        uint256 p = _initialTab.length;
        uint256 k = _initialTab.length;

        // generate random numbers
        // be aware that block.timestamp can be alter by miners.
        for (uint256 i = 0; i < k; i++) {
            uint256 randNum = (uint256(
                keccak256(abi.encodePacked(block.timestamp, _initialTab[i]))
            ) % p) + 1;

            uint256 tmp = _initialTab[randNum - 1];
            _initialTab[randNum - 1] = _initialTab[p - 1];
            _initialTab[p - 1] = tmp;
            p = p - 1;
        }
        
        //uint256[] memory res;
        //res = _initialTab;
        cards[_cardID].scarcity = defineScarcity(_initialTab[2]);
        
        // Opening a booster costs 0.05 ETH
        (bool success, ) = depositAddress.call{value: msg.value}("");
        require(success);

        return _initialTab[2];
    }
    
    function defineScarcity(uint256 _card) internal pure returns(string memory) {
        string memory str;
        
        _card == 1? str = "common" :
        _card == 2? str = "rare":
        _card == 3? str = "very rare":
        _card == 4? str = "legend":
        str = "unique";
        
        return str;
    } 
    
    function checkCardID(address _caller) public view returns(uint256) {
        return users[_caller].cardID;
    }
    
    function getScarcity(string memory _cardID) public view returns(string memory) {
        return cards[_cardID].scarcity;
    }
    
    function getSeason(string memory _cardID) public view returns(uint256) {
        return cards[_cardID].season;
    }

}
