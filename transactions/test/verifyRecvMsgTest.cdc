import IdentityVerification from "../contracts/IdentityVerification.cdc"
import ReceivedMessageContract from "../contracts/ReceivedMessageContract.cdc"
import MessageProtocol from "../contracts/MessageProtocol.cdc"

transaction (signature: String) {

    prepare(acct: AuthAccount) {
        let recvVault <- ReceivedMessageContract.createReceivedMessageVault();

        let recvData = ReceivedMessageContract.ReceivedMessageCore(id: 1, 
                                                                fromChain: "1",
                                                                sender: "2", 
                                                                sqos: MessageProtocol.SQoS(), 
                                                                resourceAccount: 0x01, 
                                                                link: "3", 
                                                                data: MessageProtocol.MessagePayload(),
                                                                session: MessageProtocol.Session(oId: 123, oType: 1, oCallback: "4", oc: [1], oa: [2]));

        
        recvVault.submitRecvMessage(recvMsg: recvData, 
                                  pubAddr: acct.address, signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, signature: signature.decodeHex());

        destroy recvVault;
    }

    execute {
        
    }
}