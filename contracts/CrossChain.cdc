
pub contract CrossChain {
    pub var Registers:[Address]; // stores all contracts' address

    // init cross chain
    init(){
        self.Registers = [];
    }

    pub event showRegisters(registers: [Address]);

    /**
      * Register current contract into cross chain contract
      * @param address - address of contract
      */
    pub fun register(address: Address): Bool{
        // append cross chain contract's address into Registers
        if(self.Registers.contains(address)){
            return false;
        }
        self.Registers.append(address);

        emit showRegisters(registers: self.Registers);
        return true;
    }

    /**
      * Query registered contract list
      */
    pub fun queryRegisters(): [Address]{
      return self.Registers;
    }
}