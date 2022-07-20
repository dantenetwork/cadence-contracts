import MessageProtocol from "./MessageProtocol.cdc"
import ReceivedMessageContract from 0xf8d6e0586b0a20c7;

transaction(){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        // prepare received message 
        let id:UInt128 = 1
        let fromChain = "Ethereum"
        let sender = self.signer
        let sqos = MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Identity, value: "")
        let resourceAccount = self.signer
        let content = content
        let link = self.signer
        let data = MessageProtocol.MessagePayload()

        let idItem = MessageProtocol.MessageItem(name: "id", type: MessageProtocol.MsgType.cdcU64, value: id)
        data.addItem(item: idItem)
        let tokenURLItem = MessageProtocol.MessageItem(name: "tokenURL", type: MessageProtocol.MsgType.cdcString, value: self.tokenURL)
        data.addItem(item: tokenURLItem)
        let ownerItem = MessageProtocol.MessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcString, value: owner)
        data.addItem(item: ownerItem)
        let hashValueItem = MessageProtocol.MessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem)

        let session = MessageProtocol.Session(oId: id, oType: 1, callback: "", commitment: 1, answer: 1)

        let receivedMessageCore = ReceivedMessageContract.ReceivedMessageCore(id:id, fromChain:fromChain, sender:sender, sqos:sqos, resourceAccount:resourceAccount, link:link, data:data, session:session)

        // Get hash received message
        // TODO

        // Submit received message
        let receivedMessageVaultRef = self.signer.borrow<&ReceivedMessageContract.ReceivedMessageVault>(from: /storage/receivedMessageVault)
        receivedMessageVaultRef.submitRecvMessage(recvMsg:receivedMessageCore, pubAddr: self.signer, signatureAlgorithm: HashAlgorithm.SHA2_256, signature:signature)
    }
}