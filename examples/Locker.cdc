import ExampleNFT from 0xf8d6e0586b0a20c7;
import MessageProtocol from 0xf8d6e0586b0a20c7;
import SentMessageContract from 0xf8d6e0586b0a20c7;
import ReceivedMessageContract from 0xf8d6e0586b0a20c7;
import NonFungibleToken from 0xf8d6e0586b0a20c7;
import MetadataViews from 0xf8d6e0586b0a20c7;

pub contract Locker{
    init(){
        // Create a new empty collection
        let collection <- ExampleNFT.createEmptyCollection()

        // save it to the account
        self.account.save(<-collection, to: ExampleNFT.CollectionStoragePath)

        // create a public capability for the collection
        self.account.link<&{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic}>(
            ExampleNFT.CollectionPublicPath,
            target: ExampleNFT.CollectionStoragePath
        )

        // create cross chain received message resource
        let receivedMessageVault <- ReceivedMessageContract.createReceivedMessageVault();
        // save message as resource
        self.account.save(<-receivedMessageVault, to: /storage/receivedMessageVault);
        self.account.link<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault, target: /storage/receivedMessageVault);
    
        // create cross chain sent message resource
        let sentMessageVault <-SentMessageContract.createSentMessageVault();
        // save message as resource
        self.account.save(<-sentMessageVault, to: /storage/sentMessageVault);
        self.account.link<&{SentMessageContract.SentMessageInterface}>(/public/sentMessageVault, target: /storage/sentMessageVault);
        // add acceptor link
        self.account.link<&{SentMessageContract.AcceptorFace}>(/public/acceptorFace, target: /storage/sentMessageVault);

        // add message submitter
        let msgSubmitter <- SentMessageContract.createMessageSubmitter();
        self.account.save(<-msgSubmitter, to: /storage/msgSubmitter);
        self.account.link<&{SentMessageContract.SubmitterFace}>(/public/msgSubmitter, target: /storage/msgSubmitter);
        
    }

    pub fun SendCrossChainMessagge(transferToken: @AnyResource, signerAddress: Address, id: UInt64, owner: String, hashValue: String){
        let transferToken <- transferToken as! @ExampleNFT.NFT
        let id: UInt64 = transferToken.id
        let tokenURL: String = transferToken.tokenURL

        // Get the locker's public account object
        let locker = self.account

        // Get the Collection reference for the locker
        // getting the public capability and borrowing a reference from it
        let lockerRef = locker.getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get locker reference to the NFT Collection");

        // Deposit the NFT in the locker collection
        lockerRef.deposit(token: <-transferToken)

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
        let tokenURLItem = MessageProtocol.MessageItem(name: "tokenURL", type: MessageProtocol.MsgType.cdcString, value: tokenURL)
        data.addItem(item: tokenURLItem)
        let ownerItem = MessageProtocol.MessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcString, value: owner)
        data.addItem(item: ownerItem)
        let hashValueItem = MessageProtocol.MessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem)

        // Send cross chain message
        let msgSubmitterRef  = locker.borrow<&SentMessageContract.Submitter>(from: /storage/msgSubmitter)
        let msg = SentMessageContract.msgToSubmit(toChain: toChain, sqos: [SQoSItem], contractName: contractName, actionName: actionName, data: data, callType: callType, callback: callback, commitment: commitment, answer: answer)
        msgSubmitterRef!.submitWithAuth(msg, acceptorAddr: locker.address, alink: "acceptorFace", oSubmitterAddr: locker.address, slink: "msgSubmitter")
    }

    pub fun ReceivedCrossChainMessage(
        signer:Address,
        id: UInt128, 
        fromChain: String, 
        toChain: String,
        sqosString: String, 
        receiver: Address,
        publicPath: String,
        hashValue: String,
        sessionId: UInt128,
        sessionType: UInt8,
        sessionCallback: String,
        sessionCommitment: String,
        sessionAnswer: String,
        signature: String
    ){
        // Get the locker's public account object
        let locker = self.account

        // prepare received message 
        // let id:UInt128 = 1
        // let fromChain = "Ethereum"
        let sender = signer.toString()
        let sqos = MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Reveal, value: sqosString)
        let resourceAccount = signer.toString()
        let link = signer.toString()
        let data = MessageProtocol.MessagePayload()

        let idItem = MessageProtocol.MessageItem(name: "id", type: MessageProtocol.MsgType.cdcU128, value: id)
        data.addItem(item: idItem)
        let ownerItem = MessageProtocol.MessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcString, value: receiver.toString())
        data.addItem(item: ownerItem)
        let hashValueItem = MessageProtocol.MessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem)

        let session = MessageProtocol.Session(oId: sessionId, oType: sessionType, callback: sessionCallback, commitment: sessionCommitment, answer: sessionAnswer)

        let receivedMessageCore = ReceivedMessageContract.ReceivedMessageCore(id: id, fromChain: fromChain, toChain: toChain, sender: signer.toString(), sqos: sqos, resourceAccount: receiver, link: publicPath, data: data, session: session)

        // Submit received message
        let lockerCapability = locker.getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault)
        if let receivedMessageVaultRef = lockerCapability.borrow(){
            receivedMessageVaultRef.submitRecvMessage(recvMsg:receivedMessageCore, pubAddr: signer, signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, signature:signature)    
        }else{
            panic("Invalid ReceivedMessageVault!");
        }
    }

    // Receiver submit random number to claim NFT
    pub fun crossChainClaim(
        signer: Address,
        fromChain: String,
        id: UInt128,
        anwser: String
    ){
        // Get the locker's public account object
        let locker = self.account

        if (self.message.containsKey(fromChain)) {
            // Hash anwser
            var originData: [UInt8] = anwser.utf8;
            let digest = HashAlgorithm.SHA2_256.hash(originData);
            let hash = String.encodeHex(digest);
            
            // Query received message
            let lockerCapability = locker.getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault)
            if let receivedMessageVaultRef = lockerCapability.borrow(){
                // Query target info
                let message = receivedMessageVaultRef.getAllMessages();
                let caches: &[ReceivedMessageCache] = message[fromChain]! as &[ReceivedMessageCache];

                let mcache = ReceivedMessageCache(id: recvMsg.id);
                var found = false;
                var cacheIdx: Int = -1;
                var items = {};

                // Match NFT id
                for idx, ele in message[fromChain]! {
                    if (id == ele.msgID) {
                        cacheIdx = idx;
                        found = true;
                        items = ele.content.data;
                        break;
                    }
                }

                if(!found){
                    panic("id is not exists");
                }

                // NFT id exists
                if (cacheIdx >= 0) {
                    // Get message contract info
                    var id: UInt64 = items[0].value;
                    var receiver: Address = items[1].value;
                    var hashValue: String = items[2].value;

                    if(hash == hashValue){
                        // Transfer NFT to receiver
                        self.transfer(id: id, receiver: receiver);
                        // Remove message from ReceivedMessageVault
                    }else{
                        panic("hash verify failed");
                    }
                        
                }


            }else{
                panic("Invalid ReceivedMessageVault!");
            }

        }else{
            panic("fromChain is not exists");
        }
    }

    // Transfer NFT back to receiver
    priv fun transfer(
        id: UInt64,
        receiver: Address
    ){
        // Borrow a reference from the stored collection
        let collectionRef = self.account.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the locker's collection")

        let nft = collectionRef.borrowExampleNFT(id: id)!

        // Call the withdraw function on the sender's Collection
        // to move the NFT out of the collection
        let token <- collectionRef.withdraw(withdrawID: id)

        // Get the Collection reference for the receiver
        // getting the public capability and borrowing a reference from it
        let receiverRef = getAccount(receiver).getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection");

        // Deposit the NFT in the receiver collection
        receiverRef.deposit(token: <-token)
    }
}