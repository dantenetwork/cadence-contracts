
pub contract CrossChain {
    pub var RegisteredRecvAccounts:[Address];   // stores all recvers' address
    pub var RegisteredSendAccounts: [Address];  // stores all senders' address
    pub var Validators:[Address];               // stores all validators' address
    

    // init cross chain
    init(){
        self.RegisteredRecvAccounts = [];
        self.Validators = [];
        slef.RegisteredSendAccounts = [];
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
    pub fun registerSendAccount(address: Address): Bool{
        // append contract's address into RegisteredContracts
        if(self.RegisteredSendAccounts.contains(address)){
            return false;
        }
        self.RegisteredSendAccounts.append(address);
        return true;
    }

    /**
      * Query registered contract list
      */
    pub fun queryRegisteredSendAccount(): [Address]{
      return self.RegisteredSendAccounts;
    }
}