import MessageProtocol from 0xf8d6e0586b0a20c7
import ReceivedMessageContract from 0xf8d6e0586b0a20c7;
import Locker from 0x01cf0e2f2f715450;

transaction(id: UInt128, 
            fromChain: String, 
            toChain: String,
            sqosString: String, 
            nftID: UInt64,
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
        Locker.receivedCrossChainMessage(
            signer: self.signer.address, 
            id: id, 
            fromChain: fromChain, 
            toChain: toChain,
            sqosString: sqosString, 
            nftID: nftID,
            receiver: receiver,
            publicPath: publicPath,
            hashValue: hashValue,
            sessionId: sessionId,
            sessionType: sessionType,
            sessionCallback: sessionCallback,
            sessionCommitment: sessionCommitment,
            sessionAnswer: sessionAnswer,
            signature: signature
        );
    }
}