import ReceivedMessageContract from 0xf8d6e0586b0a20c7;
import Locker from 0x01cf0e2f2f715450;

transaction(id: UInt64, 
            answer: String
){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer;
    }

    execute {
        let calleeRef = getAccount(0x01cf0e2f2f715450).getCapability<&{ReceivedMessageContract.Callee}>(/public/calleeVault).borrow()!;
        if (nil == calleeRef){
            panic("invalid callee address or `link`!");
        }
        calleeRef.claim(id: id, answer: answer);
    }
}