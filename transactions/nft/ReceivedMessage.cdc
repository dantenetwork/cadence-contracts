import MessageProtocol from 0xf8d6e0586b0a20c7
import ReceivedMessageContract from 0xf8d6e0586b0a20c7;

transaction(id: UInt128, 
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
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        // prepare received message 
        // let id:UInt128 = 1
        // let fromChain = "Ethereum"
        let sender = self.signer
        let sqos = MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Reveal, value: sqosString)
        let resourceAccount = self.signer
        let link = self.signer
        let data = MessageProtocol.MessagePayload()

        let idItem = MessageProtocol.MessageItem(name: "id", type: MessageProtocol.MsgType.cdcU128, value: id)
        data.addItem(item: idItem)
        let ownerItem = MessageProtocol.MessageItem(name: "receiver", type: MessageProtocol.MsgType.cdcString, value: receiver.toString())
        data.addItem(item: ownerItem)
        let hashValueItem = MessageProtocol.MessageItem(name: "hashValue", type: MessageProtocol.MsgType.cdcString, value: hashValue)
        data.addItem(item: hashValueItem)

        let session = MessageProtocol.Session(oId: sessionId, oType: sessionType, callback: sessionCallback, commitment: sessionCommitment, answer: sessionAnswer)

        let receivedMessageCore = ReceivedMessageContract.ReceivedMessageCore(id: id, fromChain: fromChain, toChain: toChain, sender: sender.address.toString(), sqos: sqos, resourceAccount: receiver, link: publicPath, data: data, session: session)

        // Submit received message
        let signerCapability = self.signer.getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(/public/receivedMessageVault)

        if let receivedMessageVaultRef = signerCapability.borrow(){
            receivedMessageVaultRef.submitRecvMessage(recvMsg:receivedMessageCore, pubAddr: self.signer.address, signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, signature:signature)    
        }else{
            panic("Invalid ReceivedMessageVault!");
        }
    }
}