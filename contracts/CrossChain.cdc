
pub contract CrossChain {
    pub var RegisteredContracts:[Address]; // stores all contracts' address

    // init cross chain
    init(){
        self.RegisteredContracts = [];
    }

    /**
      * Register contract's address into cross chain contract
      * @param address - address of contract
      */
    pub fun registerContract(address: Address): Bool{
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