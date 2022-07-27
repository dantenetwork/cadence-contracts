import ExampleNFT from 0xf8d6e0586b0a20c7
import MessageProtocol from 0xf8d6e0586b0a20c7
import SentMessageContract from 0xf8d6e0586b0a20c7
import ReceivedMessageContract from 0xf8d6e0586b0a20c7
import NonFungibleToken from 0xf8d6e0586b0a20c7
import MetadataViews from 0xf8d6e0586b0a20c7

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

        ////////////////////////////////////////////////////////////////////////////////////////////////
        // create cross chain received message resource
        let receivedMessageVault <- ReceivedMessageContract.createReceivedMessageVault()
        // save message as resource
        self.account.save(<-receivedMessageVault, to: /storage/receivedMessageVault)
        self.account.link<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault, target: /storage/receivedMessageVault)
    
        ////////////////////////////////////////////////////////////////////////////////////////////////
        // create cross chain sent message resource
        let sentMessageVault <-SentMessageContract.createSentMessageVault()
        // save message as resource
        self.account.save(<-sentMessageVault, to: /storage/sentMessageVault)
        self.account.link<&{SentMessageContract.SentMessageInterface}>(/public/sentMessageVault, target: /storage/sentMessageVault)
        // add acceptor link
        self.account.link<&{SentMessageContract.AcceptorFace}>(/public/acceptorFace, target: /storage/sentMessageVault)

        // add message submitter
        let msgSubmitter <- SentMessageContract.createMessageSubmitter()
        self.account.save(<-msgSubmitter, to: /storage/msgSubmitter)
        self.account.link<&{SentMessageContract.SubmitterFace}>(/public/msgSubmitter, target: /storage/msgSubmitter)

        ////////////////////////////////////////////////////////////////////////////////////////////////
        // create callme vault 
        // let calleeVault <- Locker.createEmptyCalleeVault()
        // save vault as resource
        self.account.save(<-create Locker.createEmptyCalleeVault(), to: /storage/calleeVault)
        self.account.link<&{ReceivedMessageContract.Callee}>(/public/calleeVault, target: /storage/calleeVault)
    }

    // Resouce to store messages from ReceivedMessageContract
    pub resource CalleeVault: ReceivedMessageContract.Callee{
        pub let receivedMessages: [MessageProtocol.MessagePayload]

        init(){
            self.receivedMessages = []
        }

        // Receive message from ReceivedMessageContract
        pub fun callMe(data: MessageProtocol.MessagePayload){
            self.receivedMessages.append(data)
        }

        pub fun getMessagesLength(): Int{
            return self.receivedMessages.length
        }

        pub fun getAllMessages(): [MessageProtocol.MessagePayload]{
            return self.receivedMessages
        }

        pub fun claim(id: UInt64, answer: String){
            // Match NFT id
            var isMatched = false
            for index,element in self.receivedMessages {
                if (element.items[0].value as? UInt64 == id) {
                    isMatched = true
                    // id matched
                    let receiver: Address = (element.items[1].value as? MessageProtocol.CDCAddress!).getFlowAddress()!
                    let hashValue: String = element.items[2].value as? String!
                        
                    let digest = HashAlgorithm.SHA2_256.hash(answer.utf8)

                    if("0x".concat(String.encodeHex(digest)) != hashValue){
                        panic("digest match failed")
                    }

                    // Receiver submit random number to claim NFT
                    Locker.transfer(id: id, receiver: receiver)

                    self.receivedMessages.remove(at: index);
                    break
                }
            }

            if(!isMatched){
                panic("id is not matched")
            }
        }
    }

    pub fun createEmptyCalleeVault(): @CalleeVault{
        return <- create CalleeVault()
    }

    // pub fun test(): AnyStruct{
    //     let digest = HashAlgorithm.SHA2_256.hash("044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217".utf8)
    //     // return "0x".concat(String.encodeHex(digest));

    //     let calleeRef = self.account.getCapability<&{ReceivedMessageContract.Callee}>(/public/calleeVault).borrow()!
    //     let hashValue: String = element.items[2].value as? String!
    //     return "0x".concat(String.encodeHex(digest)) != hashValue
    // }

    // query all callee messages
    pub fun queryMessage(): [MessageProtocol.MessagePayload]{
        let calleeRef = self.account.getCapability<&{ReceivedMessageContract.Callee}>(/public/calleeVault).borrow()!
        return calleeRef.getAllMessages()
    }

    pub fun sendCrossChainMessagge(transferToken: @AnyResource, signerAddress: Address, id: UInt64, owner: String, hashValue: String){
        let transferToken <- transferToken as! @ExampleNFT.NFT
        let id: UInt64 = transferToken.id
        let tokenURL: String = transferToken.tokenURL

        // Get the locker's public account object
        let locker = self.account

        // Get the Collection reference for the locker
        // getting the public capability and borrowing a reference from it
        let lockerRef = locker.getCapability(ExampleNFT.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get locker reference to the NFT Collection")

        // Deposit the NFT in the locker collection
        lockerRef.deposit(token: <-transferToken)

        log("NFT transferred from owner to account locker")

        // Message params
        let toChain = "Ethereum"
        let sqosItem = MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Identity, value: "")
        let contractName = "0x263037FdFa433828fCBF97B87200A0E0b8d68C5f"
        let actionName = "mintTo"
        let callType: UInt8 = 1
        let callback = ""
        let commitment = ""
        let answer = ""

        let data = MessageProtocol.MessagePayload()
        
        let idItem = MessageProtocol.createMessageItem(name: "id", type: MessageProtocol.MsgType.cdcU64, value: id as UInt64)
        data.addItem(item: idItem!)
        let tokenURLItem = MessageProtocol.createMessageItem(name: "tokenURL", type: MessageProtocol.MsgType.cdcString, value: tokenURL)
        data.addItem(item: tokenURLItem!)
        let ownerItem = MessageProtocol.createMessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcString, value: owner)
        data.addItem(item: ownerItem!)
        let hashValueItem = MessageProtocol.createMessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem!)

        // Send cross chain message
        let msgSubmitterRef  = locker.borrow<&SentMessageContract.Submitter>(from: /storage/msgSubmitter)
        let msg = SentMessageContract.msgToSubmit(toChain: toChain, sqos: [sqosItem], contractName: contractName, actionName: actionName, data: data, callType: callType, callback: callback, commitment: commitment, answer: answer)
        msgSubmitterRef!.submitWithAuth(msg, acceptorAddr: locker.address, alink: "acceptorFace", oSubmitterAddr: locker.address, slink: "msgSubmitter")
    }

    pub fun receivedCrossChainMessage(
        signer:Address,
        id: UInt128, 
        fromChain: String, 
        toChain: String,
        sqosString: String, 
        nftID: UInt64,
        receiver: String,
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
        let sender = signer.toString()

        let sqos = MessageProtocol.SQoS()
        let sqosItem = MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Reveal, value: sqosString)
        sqos.addItem(item: sqosItem)

        let resourceAccount = locker.address
        let link = publicPath
        let data = MessageProtocol.MessagePayload()

        let idItem = MessageProtocol.createMessageItem(name: "id", type: MessageProtocol.MsgType.cdcU64, value: nftID as UInt64)
        data.addItem(item: idItem!)
        let ownerItem = MessageProtocol.createMessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcAddress, value: MessageProtocol.CDCAddress(addr: receiver, t: 4))
        data.addItem(item: ownerItem!)
        let hashValueItem = MessageProtocol.createMessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem!)

        let session = MessageProtocol.Session(oId: sessionId, oType: sessionType, callback: sessionCallback, commitment: sessionCommitment.utf8, answer: sessionAnswer.utf8)

        let receivedMessageCore = ReceivedMessageContract.ReceivedMessageCore(id: id, fromChain: fromChain, sender: signer.toString(), sqos: sqos, resourceAccount: resourceAccount, link: publicPath, data: data, session: session)

        // Submit received message
        let lockerCapability = locker.getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault)
        if let receivedMessageVaultRef = lockerCapability.borrow(){
            receivedMessageVaultRef.submitRecvMessage(recvMsg:receivedMessageCore, pubAddr: signer, signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, signature:signature.decodeHex())    
        }else{
            panic("Invalid ReceivedMessageVault!")
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
            ?? panic("Could not get receiver reference to the NFT Collection")

        // Deposit the NFT in the receiver collection
        receiverRef.deposit(token: <-token)
    }
}