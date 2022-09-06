import MessageProtocol from "../../contracts/MessageProtocol.cdc"
import SentMessageContract from "../../contracts/SentMessageContract.cdc"
import ReceivedMessageContract from "../../contracts/ReceivedMessageContract.cdc"
import CrossChain from "../../contracts/CrossChain.cdc"

import MetadataViews from "./MetadataViews.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import StarRealm from  "./StarRealm.cdc"

pub contract StarLocker{
    init(){
        // // Create a new empty collection
        // let collection <- StarRealm.createStarPort();

        // // save it to the account
        // self.account.save(<-collection, to: StarRealm.PortStoragePath);

        // // create a public capability for the collection
        // self.account.link<&{StarRealm.StarDocker}>(
        //     StarRealm.DockerPublicPath,
        //     target: StarRealm.PortStoragePath
        // );

        ////////////////////////////////////////////////////////////////////////////////////////////////
        // create cross chain received message resource
        let receivedMessageVault <- ReceivedMessageContract.createReceivedMessageVault()
        // save message as resource
        self.account.save(<-receivedMessageVault, to: /storage/receivedMessageVault)
        self.account.link<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault, target: /storage/receivedMessageVault)
        CrossChain.registerRecvAccount(address: self.account.address, link: "receivedMessageVault");

        ////////////////////////////////////////////////////////////////////////////////////////////////
        // create cross chain sent message resource
        let sentMessageVault <-SentMessageContract.createSentMessageVault()
        // save message as resource
        self.account.save(<-sentMessageVault, to: /storage/sentMessageVault)
        self.account.link<&{SentMessageContract.SentMessageInterface, SentMessageContract.AcceptorFace}>(/public/sentMessageVault, target: /storage/sentMessageVault)
        // add acceptor link
        // self.account.link<&{SentMessageContract.AcceptorFace}>(/public/acceptorFace, target: /storage/sentMessageVault)
        CrossChain.registerSendAccount(address: self.account.address, link: "sentMessageVault");

        // add message submitter
        let msgSubmitter <- SentMessageContract.createMessageSubmitter()
        self.account.save(<-msgSubmitter, to: /storage/msgSubmitter)
        self.account.link<&{SentMessageContract.SubmitterFace}>(/public/msgSubmitter, target: /storage/msgSubmitter)

        ////////////////////////////////////////////////////////////////////////////////////////////////
        // create callme vault 
        // let calleeVault <- Locker.createEmptyCalleeVault()
        // save vault as resource
        self.account.save(<-create StarLocker.createEmptyCalleeVault(), to: /storage/calleeVault)
        self.account.link<&{ReceivedMessageContract.Callee}>(/public/calleeVault, target: /storage/calleeVault)
        // self.account.link<&{StarRealm.StarDocker}>(/public/LockerDocker, target: /storage/calleeVault)
    }

    // Resouce to store messages from ReceivedMessageContract
    pub resource CalleeVault: ReceivedMessageContract.Callee{
        pub let receivedMessages: [MessageProtocol.MessagePayload]
        // priv let lockedNFTs: @{UInt64: AnyResource{NonFungibleToken.INFT}};

        // {domain: {NFT ID: Resource}}
        priv let lockedNFTs: @{String: {UInt64: AnyResource{NonFungibleToken.INFT}}};

        init(){
            self.receivedMessages = []
            self.lockedNFTs <- {};
        }

        destroy () {
            destroy self.lockedNFTs;
        }

        // There will be one id exists at a time
        pub fun locking(nft: @AnyResource{NonFungibleToken.INFT}): @AnyResource{NonFungibleToken.INFT}? {
            let nftID = nft.id;
            let NFTResolver <- nft as! @AnyResource{MetadataViews.Resolver};

            let nftView = MetadataViews.getNFTView(id: nftID, viewResolver: &NFTResolver as &{MetadataViews.Resolver});

            var domain: String = "";
            if let display = nftView.display {
                domain = display.name;
            } else {
                domain = "default domain";
            }

            let nftBack <- NFTResolver as! @AnyResource{NonFungibleToken.INFT};

            if let domainRef: &{UInt64: AnyResource{NonFungibleToken.INFT}} = 
                                            &self.lockedNFTs[domain] as &{UInt64: AnyResource{NonFungibleToken.INFT}}? {
                if domainRef.containsKey(nftID) {
                    return <- nftBack;
                } else {
                    domainRef[nftID] <-! nftBack;
                    return nil;
                }
            } else {
                let domainRes <- {nftID: <- nftBack};
                self.lockedNFTs[domain] <-! domainRes;
                return nil;
            }
        }

        // This is a temporary solutions
        // Receive message from ReceivedMessageContract
        pub fun callMe(data: MessageProtocol.MessagePayload, contextID: String){
            self.receivedMessages.append(data)
        }

        pub fun getMessagesLength(): Int{
            return self.receivedMessages.length
        }

        pub fun getAllMessages(): [MessageProtocol.MessagePayload]{
            return self.receivedMessages
        }

        pub fun getLockedNFTs(): {String: [UInt64]} {
            let output: {String: [UInt64]} = {};
            for eleKey in self.lockedNFTs.keys {
                let domainRef: &{UInt64: AnyResource{NonFungibleToken.INFT}} = (&self.lockedNFTs[eleKey] as! &{UInt64: AnyResource{NonFungibleToken.INFT}}?)!;
                output[eleKey] = domainRef.keys;
            }
            return output;
        }

        pub fun claim(domain: String, id: UInt64, answer: String){
            // Match NFT id
            var isMatched = false
            for index,element in self.receivedMessages {
                if (element.getItem(name: "domain")!.value as? String == domain) && 
                    (element.getItem(name: "id")!.value as? UInt64 == id) {
                    isMatched = true
                    // id matched
                    let receiver: Address = (element.getItem(name: "receiver")!.value as? MessageProtocol.CDCAddress!).getFlowAddress()!
                    let hashValue: String = element.getItem(name: "hashValue")!.value as? String!
                        
                    let digest = HashAlgorithm.KECCAK_256.hash(answer.utf8)

                    if(String.encodeHex(digest) != hashValue){
                        panic("digest match failed")
                    }

                    // Receiver submit random number to claim NFT
                    self.transfer(domain: domain, id: id, receiver: receiver)

                    self.receivedMessages.remove(at: index);
                    break
                }
            }

            if(!isMatched){
                panic("id is not matched")
            }
        }

        // Transfer NFT back to receiver
        priv fun transfer(
            domain: String,
            id: UInt64,
            receiver: Address
        ){
            // log(domain.concat(id.toString()));

            if let starDockerRef = StarRealm.getStarDockerFromAddress(addr: receiver) {
                if self.lockedNFTs.containsKey(domain) {
                    let domainRef: &{UInt64: AnyResource{NonFungibleToken.INFT}} = (&self.lockedNFTs[domain] as! &{UInt64: AnyResource{NonFungibleToken.INFT}}?)!;

                    let v <- starDockerRef.docking(nft: <- domainRef.remove(key: id)!);
                    if v != nil {
                        panic("Transfer failed when docking!");
                    } else {
                        destroy v;
                    }
                } else {
                    panic("The id of NFT has not been locked!");
                }
            } else {
                panic("star docker does not exist!");
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
        let calleeRef = self.account.borrow<&StarLocker.CalleeVault>(from: /storage/calleeVault)!
        return calleeRef.getAllMessages()
    }

    // This is a temporary solutions
    pub fun sendoutNFT(transferToken: @AnyResource, 
                        toChain: String,
                        contractName: [UInt8],
                        actionName: [UInt8],
                        receiver: MessageProtocol.CDCAddress, 
                        hashValue: String){

        let NFTResolver <- transferToken as! @AnyResource{MetadataViews.Resolver};
        // let nftView = MetadataViews.getNFTView(id: id, viewResolver: &NFTResolver as &{MetadataViews.Resolver});
        let nftDisplay = MetadataViews.getDisplay(&NFTResolver as & {MetadataViews.Resolver});
        var tokenURL: String = nftDisplay!.thumbnail.uri();
        let domain = nftDisplay!.name;
        // tokenURL = tokenURL.slice(from: 7, upTo: tokenURL.length);
        // tokenURL = "http://47.242.71.251:8080/ipfs/".concat(tokenURL);

        let NonToken <- NFTResolver as! @AnyResource{NonFungibleToken.INFT};
        let id: UInt64 = NonToken.id

        // Get the locker's public account object
        let locker = self.account

        // Get the Collection reference for the locker
        // getting the public capability and borrowing a reference from it
        let lockerRef = locker.borrow<&CalleeVault>(from: /storage/calleeVault) ?? panic("Could not get locker reference to the StarRealm")

        // Deposit the NFT in the locker collection
        let v <- lockerRef.locking(nft: <- NonToken);

        if v != nil {
            panic("NFT docking failed, the `id` exists!")
        } else {
            destroy v;
        }

        log("NFT transferred from owner to account locker")

        // Message params
        let sqos = MessageProtocol.SQoS()
        let callType: UInt8 = 1
        let callback: [UInt8] = []
        let commitment: [UInt8] = []
        let answer: [UInt8] = []

        let data = MessageProtocol.MessagePayload()
        
        let domainItem = MessageProtocol.createMessageItem(name: "domain", type: MessageProtocol.MsgType.cdcString, value: domain)
        data.addItem(item: domainItem!)
        let idItem = MessageProtocol.createMessageItem(name: "id", type: MessageProtocol.MsgType.cdcU64, value: id as UInt64)
        data.addItem(item: idItem!)
        let tokenURLItem = MessageProtocol.createMessageItem(name: "tokenURL", type: MessageProtocol.MsgType.cdcString, value: tokenURL)
        data.addItem(item: tokenURLItem!)
        let ownerItem = MessageProtocol.createMessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcAddress, value: receiver)
        data.addItem(item: ownerItem!)
        let hashValueItem = MessageProtocol.createMessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem!)

        // Send cross chain message
        let msgSubmitterRef  = locker.borrow<&SentMessageContract.Submitter>(from: /storage/msgSubmitter)
        let msg = SentMessageContract.msgToSubmit(toChain: toChain, sqos: sqos, contractName: contractName, actionName: actionName, data: data, callType: callType, callback: callback, commitment: commitment, answer: answer)
        msgSubmitterRef!.submitWithAuth(msg, acceptorAddr: locker.address, alink: "sentMessageVault", oSubmitterAddr: locker.address, slink: "msgSubmitter")
    }

    pub fun claimNFT(domain: String, id: UInt64, answer: String) {
        let locker = self.account;

        let calleeVaultRef = locker.borrow<&StarLocker.CalleeVault>(from: /storage/calleeVault)!;

        calleeVaultRef.claim(domain: domain, id: id, answer: answer);
    }

    pub fun getLockedNFTs(): {String: [UInt64]} {
        let locker = self.account;

        let calleeVaultRef = locker.borrow<&StarLocker.CalleeVault>(from: /storage/calleeVault)!;

        return calleeVaultRef.getLockedNFTs();
    }
}
