# set-in-stone

This repository has been created in order to publish a demo of my interview with Thomas, CEO of Set In Stone.

To Thomas,

*Dear Thomas, in order to show how one could proceed, I published some files of a personal project that is similar to the Rugby game exercice. What is called card can be tought of as Pool. As a card, a Pool is defined as structure that defines Pool's variables. These variables - which represent properties of the Pool - can be static (in that case, they are defined during the Pool creation) or dynamique (in that case one needs a function that can modify them).*

# Minting NFTs (ERC721 tokens)

ERC721 is a standard interface for non-fungible tokens (NFT). It defines an Interface that must be imported and defined in a contract which allows minting NFTs. The interface can be found here [[ERC721 interface]](https://eips.ethereum.org/EIPS/eip-721). In the __*NFT.sol*__ contract that I proposed, the openzeppelin library has been used, which provides a ready to use ERC721 interface, this openzeppelin interface can be found here [[ERC721 interface, openzeppelin]](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol). One then needs to define our function that allows to trigger all operations needed when minting the NFT, this is the _*mintImage*_ function defined in line 43 of __*NFT.sol*__ contract. The image can be replaced by a card.

```solidity
// mintImage
function mintImage(string memory _imageCID) public {
        // cannot mint the same image twice.
        // IPFS will be used to store images returning a unique CID (image URI).
        // Since CIDs are based on the image content, same image will always
        // return same CID.
        require(!imageAlreadyMinted[_imageCID], "image already minted");
        uint256 newImageId = counter;

        // store the image URI on the Blockchain
        images.push(_imageCID);

        // mint the image
        _safeMint(msg.sender, newImageId);

        // store the information that the image has been minted
        imageAlreadyMinted[_imageCID] = true;

        // store the image ID of the image in a mapping
        imageIDs[_imageCID] = newImageId;

        // transfer the ownership of the image
        owner = payable(ownerOf(newImageId));

        counter++;
    }
```

# Rugby Game

The rugby game that we discussed today is similar to one of my personal project that I called Pool game (see the contract _*PoolGame.sol*_). As you can see, I created a structure called VPool (line 12) that defines all properties of the Pool (which can be tought of as the card in our case). The *Card structure* could be defined as the VPool structure.

```solidity
// VPool structure
struct VPool {
        bool registered;
        string ID;
        uint256 price;
        uint256 prize;
        uint256 numberOfUsers;
        uint256 numberOfVoters;
        uint256 startRegistrationTime;
        uint256 endRegistrationTime;
        uint256 endTime;
        mapping(address => bool) userVoted;
        mapping(address => uint256) userVote;
        mapping(uint256 => address) voterAddresses;
        mapping(address => bool) userWithdrawed;
    }
    
 //====================================
 //           CARD STRUCTURE
 //====================================
 struct Card {
        address creator    // l'adresse de l'utilisateur qui a créé la carte
        string cardID;
        bool created;
        string position;   // or uint256
        string firstname;
        string lastname;
        string club;
        string scarcity;   // rareté
        string season;     // saison
        uint256 strength;  // Force
        uint256 endurance;
        uint256 speed;     // vitesse
        uint256 level;     // level
        uint256 amount;    // le montant à payer pour ouvrir un booster
        uint256 openMode;  // 0 quand la carte est créée via un échange, et 1 quand elle créée en ouvrant un booster
    }
```
Other properties can be added to the Card structure in case they are necessary. To create a new Card, one needs to create a function, similar to the _*RegisterOrJoinPool*_ in  _*PoolGame.sol*_ smart contract (line 88). It takes two parameters, the VPool ID (string) and an amount of tokens that is necessary to join the VPool. In the case of the Rugby game, the _*CreateCard*_ function can take same parameteres (Card ID, amount to pay to open a booster), plus all properties that need to be defined at Card creation.

```solidity
// CreateCard.sol
function CreateCard(
        string  _CardID,
        uint256 _amount,
        string _position,
        string firstname,
        string _lastname,
        string _club,
        string _scarcity,
        string _season,
        uint256 _strength,
        uint256 _endurance,
        uint256 _speed,
        uint256 level,
        uint256 _openMode
) public {
        // here I supposed there exists a mapping between an address (user address) and the Card structure
        // mapping(address => Card) internal cards;
        
        cards[msg.sender].creator = msg.sender;
        cards[msg.sender].cardID = _CardID;
        cards[msg.sender].created = true;
        cards[msg.sender].position = _position;
        cards[msg.sender].firstname = _firstname;
        cards[msg.sender].lastname = _lastname;
        cards[msg.sender].club = _club;
        cards[msg.sender].scarcity = _scarcity;
        cards[msg.sender].season = _season;
        cards[msg.sender].strength = _strength;
        cards[msg.sender].endurance = _endurance;
        cards[msg.sender].speed = _speed;
        cards[msg.sender].level = _level;
        cards[msg.sender].amount = _amount;
        cards[msg.sender].OpenMode = _openMode;
    }
```














