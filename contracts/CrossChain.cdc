
pub contract CrossChain {
    pub var RegisteredContracts:[Address]; // stores all contracts' address
    pub var Validators:[Address]; // stores all validators' address

    // init cross chain
    init(){
        self.RegisteredContracts = [];
        self.Validators = [];
    }

    /**
      * Register the address of accouts wanna to receive visiting from other chains into cross chain contract
      * @param address - address of account
      */
    pub fun registerRecvAccount(address: Address): Bool{
        // append contract's address into RegisteredContracts
        if(self.RegisteredContracts.contains(address)){
            return false;
        }
        self.RegisteredContracts.append(address);
        return true;
    }

    /**
      * Query registered contract list
      */
    pub fun queryRegisteredContracts(): [Address]{
      return self.RegisteredContracts;
    }
}