import CrossChainMessage from 0x01;

pub contract CrossChain {
    pub let messageRecord: [String];

    init(){
        self.messageRecord = [];
    }

    // This mechanism can be used in cross-chain msg send
    // 
    // The first param `addr` is the sender, the message is stored by the sender in his /storage/crossChainMessage. 
    // and the sender create a `Capability` `link` of /public/messageQueue
    // See `MessageVisitor.cdc`, `createMessage` for details
    // 
    // So when the sender will send cross-chain messages, he calls this method, input his addr, so the corss-chain contract could know who's sending messages
    // This is exactly a classic case for `resource-oriented` programming
    pub fun sendMessage(address: Address): Bool{
        // access account 
        let sender = getAccount(address);
        let messageCapability = sender.getCapability<&{CrossChainMessage.MessageInterface}>(/public/crossChainMessage);
        let messageReference = messageCapability.borrow()!;
        
        // append cross chain message into record
        self.messageRecord.append(messageReference.msg);
        return true;
    }

    pub fun queryLastMessage():String{
        return self.messageRecord[self.messageRecord.length-1]
    }
}
