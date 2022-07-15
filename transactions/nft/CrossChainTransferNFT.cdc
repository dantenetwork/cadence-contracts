import ExampleNFT from 0xf8d6e0586b0a20c7;
import MessageProtocol from 0xf8d6e0586b0a20c7;
import SentMessageContract from 0xf8d6e0586b0a20c7;
import NonFungibleToken from 0xf8d6e0586b0a20c7;
import MetadataViews from 0xf8d6e0586b0a20c7;

// This transaction transfers an NFT from one user's collection
// to another user's collection.
transaction(
    id: UInt64,
    owner: String,
    hashValue: String
) {
    let signer: AuthAccount;
    // The field that will hold the NFT as it is being
    // transferred to the other account
    let transferToken: @NonFungibleToken.NFT;
    let tokenURL: String;
	
    prepare(signer: AuthAccount) {
        self.signer = signer;
        // Borrow a reference from the stored collection
        let collectionRef = signer.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")

        let nft = collectionRef.borrowExampleNFT(id: id)!

         // Get the basic display information for this NFT
        let view = nft.resolveView(Type<MetadataViews.Display>())!

        let display = view as! MetadataViews.Display
        self.tokenURL = display.tokenURL

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        self.transferToken <- collectionRef.withdraw(withdrawID: id)
    }

    execute {
        // Get the locker's public account object
        let locker = getAccount(0x01cf0e2f2f715450)

        // Get the Collection reference for the locker
        // getting the public capability and borrowing a reference from it
        let lockerRef = locker.getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get locker reference to the NFT Collection");

        // Deposit the NFT in the locker collection
        lockerRef.deposit(token: <-self.transferToken)

        log("NFT transferred from owner to account locker")

        // Message params
        let toChain = "Ethereum"
        let SQoSItem = MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Identity, value: "")
        let contractName = "0x263037FdFa433828fCBF97B87200A0E0b8d68C5f"
        let actionName = "mintTo"
        let callType: UInt8 = 1
        let callback = ""
        let commitment = ""
        let answer = ""

        let data = MessageProtocol.MessagePayload()
        
        let idItem = MessageProtocol.MessageItem(name: "id", type: MessageProtocol.MsgType.cdcU64, value: id)
        data.addItem(item: idItem)
        let tokenURLItem = MessageProtocol.MessageItem(name: "tokenURL", type: MessageProtocol.MsgType.cdcString, value: self.tokenURL)
        data.addItem(item: tokenURLItem)
        let ownerItem = MessageProtocol.MessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcString, value: owner)
        data.addItem(item: ownerItem)
        let hashValueItem = MessageProtocol.MessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem)

        // Send cross chain message
        let msgSubmitterRef = self.signer.borrow<&SentMessageContract.Submitter>(from: /storage/msgSubmitter)
        let msg = SentMessageContract.msgToSubmit(toChain: toChain, sqos: [SQoSItem], contractName: contractName, actionName: actionName, data: data, callType: callType, callback: callback, commitment: commitment, answer: answer)
        msgSubmitterRef!.submitWithAuth(msg, acceptorAddr: self.signer.address, alink: "acceptorFace", oSubmitterAddr: self.signer.address, slink: "msgSubmitter")
        
    }
}
 