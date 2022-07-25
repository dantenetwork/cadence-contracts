import ExampleNFT from 0xf8d6e0586b0a20c7;
import MessageProtocol from 0xf8d6e0586b0a20c7;
import SentMessageContract from 0xf8d6e0586b0a20c7;
import NonFungibleToken from 0xf8d6e0586b0a20c7;
import MetadataViews from 0xf8d6e0586b0a20c7;

pub contract Locker{
    init(){
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

    pub fun ReceivedCrossChainMessage(){

    }
}