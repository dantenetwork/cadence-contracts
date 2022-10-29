
pub contract CrossChain {
    pub let registeredRecvAccounts: {Address: String};   // stores all recvers' address
    pub let registeredSendAccounts: {Address: String};  // stores all senders' address
    pub let validators:[Address];               // stores all validators' address


    // init cross chain
    init(){
        self.registeredRecvAccounts = {};
        self.validators = [];
        self.registeredSendAccounts = {};
    }

    /**
    * Register the address of accouts wanna to receive visiting from other chains into cross chain contract
    * @param address - address of account
    */
    access(account) fun registerRecvAccount(address: Address, link: String): Bool{
        // add or update contract's address into RegisteredContracts
        self.registeredRecvAccounts[address] = link;
        return true;
    }

    /*Remove registered recver. Needs signature verification */ 
    access(account) fun removeRecvAccount(address: Address, link: String): Bool {
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
    access(account) fun registerSendAccount(address: Address, link: String): Bool{
        self.registeredSendAccounts[address] = link;
        return true;
    }

    /// Remove registered sender. Needs signature verification
    access(account) fun removeSendAccount(address: Address, link: String): Bool {
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
