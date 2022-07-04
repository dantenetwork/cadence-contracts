import SentMessageContract from 0x01
import ReceivedMessageContract from 0x01

pub contract CrossChain {
    pub var registeredRecvAccounts: {Address, String};   // stores all recvers' address
    pub var registeredSendAccounts: {Address, String};  // stores all senders' address
    pub var validators:[Address];               // stores all validators' address
    

    // init cross chain
    init(){
        self.registeredRecvAccounts = [];
        self.validators = [];
        slef.registeredSendAccounts = {};
    }

    /**
      * Register the address of accouts wanna to receive visiting from other chains into cross chain contract
      * @param address - address of account
      */
    pub fun registerRecvAccount(address: Address, link: String): Bool{
        let pubLink = PublicPath(identifier: link);
        let recverRef = getAccount(address).getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
        if (!recverRef.isValidRecver()) {
            panic("invalid recver address or `link`!")
            return false;
        }
        
        // add or update contract's address into RegisteredContracts
        self.registeredRecvAccounts[address] = link;
        return true;
    }

    /*Remove registered recver. Needs signature verification */ 
    pub fun removeRecvAccount(address: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]): Bool {
        // Verify the signature
        let pubAcct = getAccount(address);
        let pk = PublicKey(publicKey: pubAcct.keys.get(keyIndex: 0)!.decodeHex(), 
                            signatureAlgorithm: signatureAlgorithm);
        if (!pk.verify(signature: signature,
                        signedData: address.toBigEndianBytes(),
                        domainSeparationTag: "",
                        hashAlgorithm: HashAlgorithm.SHA2_256)) {
            panic("invalid recver address or `link`!")
            return false;
        }

        self.registeredRecvAccounts.remove(key: address);
        return true;
    }

    /**
      * Query registered contract list
      */
    pub fun queryRegisteredRecvAccount(): [Address]{
        return self.registeredRecvAccounts.keys;
    }

    /**
      * Register the address of accouts wanna to send messages to other chains' contract
      * @param address - address of account
      */
    pub fun registerSendAccount(address: Address, link: String): Bool{
        let pubLink = PublicPath(identifier: link);
        let senderRef = getAccount(address).getCapability<&{SentMessageContract.SentMessageInterface}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
        if (!senderRef.isValidSender()) {
            panic("invalid sender address or `link`!")
            return false;
        }
        
        // add or update contract's address into RegisteredContracts
        self.registeredSendAccounts[address] = link;

        return true;
    }

    /// Remove registered sender. Needs signature verification
    pub fun removeSendAccount(address: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]): Bool {
        // Verify the signature
        let pubAcct = getAccount(address);
        let pk = PublicKey(publicKey: pubAcct.keys.get(keyIndex: 0)!.decodeHex(), 
                            signatureAlgorithm: signatureAlgorithm);
        if (!pk.verify(signature: signature,
                        signedData: address.toBigEndianBytes(),
                        domainSeparationTag: "",
                        hashAlgorithm: HashAlgorithm.SHA2_256)) {
            panic("invalid sender address or `link`!")
            return false;
        }

        self.registeredSendAccounts.remove(key: address);
        return true;
    }

    /**
      * Query registered contract list
      */
    pub fun queryRegisteredSendAccount(): [Address]{
      return self.registeredSendAccounts.keys;
    }
}
