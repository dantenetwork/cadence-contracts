import SentMessageContract from 0x01

pub contract CrossChain {
    pub var RegisteredRecvAccounts:[Address];   // stores all recvers' address
    pub var RegisteredSendAccounts: {Address, String};  // stores all senders' address
    pub var Validators:[Address];               // stores all validators' address
    

    // init cross chain
    init(){
        self.RegisteredRecvAccounts = [];
        self.Validators = [];
        slef.RegisteredSendAccounts = {};
    }

    /**
      * Register the address of accouts wanna to receive visiting from other chains into cross chain contract
      * @param address - address of account
      */
    pub fun registerRecvAccount(address: Address): Bool{
        // append contract's address into RegisteredContracts
        if(self.RegisteredRecvAccounts.contains(address)){
            return false;
        }
        self.RegisteredRecvAccounts.append(address);
        return true;
    }

    /**
      * Query registered contract list
      */
    pub fun queryRegisteredRecvAccount(): [Address]{
        return self.RegisteredRecvAccounts;
    }

    /**
      * Register the address of accouts wanna to send messages to other chains' contract
      * @param address - address of account
      */
    pub fun registerSendAccount(address: Address, link: String): Bool{
        let pubLink = PublicPath(identifier: link);
        let senderRef = getAccount(msgSender).getCapability<&{SentMessageContract.SentMessageInterface}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
        if (!senderRef.isValidSender()) {
            return false;
        }
        
        // add or update contract's address into RegisteredContracts
        self.registerSendAccount[address] = link;

        return true;
    }

    /// Remove registered sender. Needs signature verification
    pub fun removeSendAccount(address: Address, signatureAlgorithm: SignatureAlgorithm, signature: [UInt8]): Bool {
        // Verify the signature
        let pubAcct = getAccount(pubAddr);
        let pk = PublicKey(publicKey: pubAcct.keys.get(keyIndex: 0)!.decodeHex(), 
                            signatureAlgorithm: signatureAlgorithm);
        if (!pk.verify(signature: signature,
                        signedData: address.toBigEndianBytes(),
                        domainSeparationTag: "",
                        hashAlgorithm: HashAlgorithm.SHA2_256)) {
            return false;
        }

        self.registerSendAccount.remove(key: address);
        return true;
    }

    /**
      * Query registered contract list
      */
    pub fun queryRegisteredSendAccount(): [Address]{
      return self.RegisteredSendAccounts;
    }
}