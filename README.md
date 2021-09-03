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
        uint256 season;    // saison
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
        uint256 _season,
        uint256 _strength,
        uint256 _endurance,
        uint256 _speed,
        uint256 level,
        uint256 _openMode
) public {
        // here I supposed there exists a mapping between an address (user address) and the Card structure
        // mapping(address => Card) internal cards;
        
        // Define all the requires here (for example the Card must not be registered, etc...) 
        
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

## Random number generator

The generation of random number in solidity is active field of research. Two solutions are proposed in this demo, the first one consists of using the _*ChainLink Verifiable Random Function*_ to generate a random number ([[ERC721 interface]](https://docs.chain.link/docs/chainlink-vrf/#:~:text=Chainlink%20VRF%20(Verifiable%20Random%20Function,Blockchain%20games%20and%20NFTs)), this requires filling the contract with Link tokens and requiring the user that call the contract to have somre Link tokens in their wallets. The second method that I proposed and that is implemented in my Pool game is to define a function _*randDistribution*_ in the smart contract that generates a random number. To avoid paying gas fees when calling this function, no state variable must be modified inside the function, therefore, this must be a view function that return a random number. Let's suppose one needs to generate N distinct random numbers, the following function allows to accomplish that task.

```solidity
// generates an array of random numbers between 1 and the length of the array
    function randomNumbersGerator(
        string memory _cardID,
        uint256[] memory _initialTab
    ) public view returns (uint256[] memory) {
        // all requires must be set here

        uint256 p = _initialTab.length;
        uint256 k = _initialTab.length;

        // generate random numbers
        // be aware that block.timestamp can be alter by miners.
        for (uint256 i = 0; i < k; i++) {
            uint256 randNum = (uint256(
                keccak256(abi.encodePacked(block.timestamp, _cardID, _initialTab[i]))
            ) % p) + 1;

            uint256 tmp = _initialTab[randNum - 1];
            _initialTab[randNum - 1] = _initialTab[p - 1];
            _initialTab[p - 1] = tmp;
            p = p - 1;
        }

        uint256[] memory res;
        res = _initialTab;

        return res;
    }
```

The above function generates an array of distinct random numbers, the length of this array is equal to the length of the initial array given as parameter. The _*_initialTab*_ array must be constructed such that to have 1 at index 0, 2 at index 1, 3 at index 2, ...., N at index N - 1. Where _*N*_ is the number of random number one would like to generate. The random numbers generated are in the range 1 - N.

```solidity
// the _initialTab for generating 5 random numbers
_initialTab[0] = 1;
_initialTab[1] = 2;
_initialTab[2] = 3;
_initialTab[3] = 4;
_initialTab[4] = 5;
```

## Video (random numbers generator)

This video shows the generation of random numbers by using the function _*randomNumbersGerator*_ define above.

[![IMAGE ALT TEXT HERE](https://github.com/Edoumou/set-in-stone/blob/main/cover.png)](https://youtu.be/oarR6yuxyyE)















