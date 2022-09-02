import StarLocker from "../contracts/StarLocker.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"
import SentMessageContract from "../../contracts/SentMessageContract.cdc"
import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"

pub fun receiveNFT() {
    
}

pub fun main(address: Address) {

    // log(CrossChain.queryRegisteredSendAccount());
    // log(CrossChain.queryRegisteredRecvAccount());

    let authAccount = getAuthAccount(address);

    let collectionRef = authAccount.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!;
    let minterRef = authAccount.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)!;
    let senderRef = authAccount.borrow<&SentMessageContract.SentMessageVault>(from: /storage/sentMessageVault)!;
    let recverRef = authAccount.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault)!;

    let examplePublicRef = ExampleNFT.getExamplePubblic(addr: address);
    let collectionPublicRef = ExampleNFT.getCollectionPublic(addr: address);

    var loop = 0;
    while loop < 10 {
        minterRef.mintNFT(recipient: collectionPublicRef,
            name: "Example Series",
            description: "Hello Kitty",
            thumbnail: "ipfsurl",
            royalties: []);
        
        loop = loop + 1;
    }
    
    // log(examplePublicRef.getIDs());

    /////////////////////////////////////////////////////////////////////////////////////////
    // Test Send NFT out
    let nft2sendout <- collectionRef.withdraw(withdrawID: 3);
    // log(examplePublicRef.getIDs());

    let answer = "Hello Moon";
    let hashValue = String.encodeHex(HashAlgorithm.KECCAK_256.hash(answer.utf8));

    StarLocker.sendoutNFT(transferToken: <-nft2sendout, 
                                receiver: "Moon", 
                                hashValue: hashValue);

    log(StarLocker.getLockedNFTs());
    log(senderRef.getAllMessages());

    ////////////////////////////////////////////////////////////////////////////////////////
    // Test receive NFT and unlock

}
