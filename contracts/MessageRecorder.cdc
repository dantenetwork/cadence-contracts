pub contract MessageRecorder {
    access(contract) var messageIDs: {String: UInt128};

    init() {
        self.messageIDs = {};
    }

    pub fun getNextMessageID(chain: String): UInt128 {
        if let id_to_chain = self.messageIDs[chain] {
            let id = id_to_chain;
            if id == UInt128.max {
                self.messageIDs[chain] = 1;
            } else {
                self.messageIDs[chain] = id_to_chain + 1;
            }

            return id;

        } else {
            self.messageIDs[chain] = 2;
            return 1;
        }
    }

    pub fun getID(chain: String): UInt128 {
        if let id_out = self.messageIDs[chain] {
            return id_out - 1;
        } else {
            return 0;
        }
    }

    // for test
    pub fun changeMessageIDForce(chain: String, id: UInt128) {
        self.messageIDs[chain] = id;
    }
}