# set-in-stone

This repository has been created in order to publish a demo of my interview with Thomas, CEO of Set In Stone.

To Thomas,

*Dear Thomas, in order to show how one could proceed, I published some files of a personal project that is similar to the Rugby game exercice. What is called card can be tought of as Pool. As a card, a Pool is defined as structure that defines Pool's variables. These variables - which represent properties of the Pool - can be static (in that case, they are defined during the Pool creation) or dynamique (in that case one needs a function that can modify them).*

# Minting NFTs (ERC721 tokens)

ERC721 is a standard interface for non-fungible tokens (NFT). It defines an Interface that must be imported and defined in a contract which allows minting NFTs. The interface can be found here [[ERC721 interface]](https://eips.ethereum.org/EIPS/eip-721). In the __*NFT.sol*__ contract that I proposed, the openzeppelin library has been used, which provides a ready to use ERC721 interface, this openzeppelin interface can be found here [[ERC721 interface, openzeppelin]](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol). One then needs to define our function that allows to trigger all operations needed when minting the NFT, this is the _*mintImage*_ function defined in line 43 of __*NFT.sol*__ contract:

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















