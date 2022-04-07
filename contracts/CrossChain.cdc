
pub contract CrossChain {
    pub var RegisteredContracts:[Address]; // stores all contracts' address
    pub var Validators:[Address]; // stores all validators' address

    // init cross chain
    init(){
        self.RegisteredContracts = [];
        self.Validators = [];
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

    /**
      * Register validator's address into cross chain contract
      * @param address - address of contract
      */
    pub fun registerValidator(address: Address): Bool{
        // append validator's address into Validators
        if(self.Validators.contains(address)){
            return false;
        }
        self.Validators.append(address);
        return true;
    }

    /**
      * Query validator list
      */
    pub fun queryValidators(): [Address]{
      return self.Validators;
    }

    /**
      * Called from cross-chain node for re-selecting nodes for this time stage
      */
    pub fun selectValidators(){
      // TODO
    }

    /**
      * Called from `messageVerify` to get the credibilities of validators to take weighted aggregation verification of messages
      */
    pub fun getValidatorCredibility(){
      // TODO
    }

    /**
      * Called from `messageVerify`. Update validator credibility by node behaviors after message verification.
      */
    pub fun updateValidatorCredibility(){
      // TODO
    }

    /**
      * Set the value of the credibility of the newly added validator
      */
    pub fun setInitialCredibility(initValue: Int){
      // TODO
    }
}