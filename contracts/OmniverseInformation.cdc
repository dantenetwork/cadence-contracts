pub contract OmniverseInformation {

    pub let a4: [UInt8];
    pub let a8: [UInt8];
    pub let a20: [UInt8];
    pub let a32: [UInt8];

    init() {
        self.a4 = [0, 0, 0, 0];
        self.a8 = [0, 0, 0, 0, 0, 0, 0, 0];
        self.a20 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        self.a32 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    }

    pub fun getDefaultAddress(chainName: String): [UInt8] {
        if ("FLOWTEST" == chainName) || ("FLOWMAIN" == chainName) || ("FLOWEMU" == chainName) {
            return self.a8;
        } 

        if ("POLKADOT" == chainName) {
            return self.a32;
        }
        
        return self.a20;
    }

    pub fun judgeValidAddress(chainName: String, address: [UInt8]): Bool {
        if ("FLOWTEST" == chainName) || ("FLOWMAIN" == chainName) || ("FLOWEMU" == chainName) {
            return 8 == address.length;
        }

        if ("POLKADOT" == chainName) {
            return 32 == address.length;
        }
        
        return 20 == address.length;
    }

    pub fun getDefaultSelector(chainName: String): [UInt8] {
        
        return self.a4;
    }

    pub fun judgeValidSelector(chainName: String, selector: [UInt8]): Bool {
        
        return 4 == selector.length;
    }
}
