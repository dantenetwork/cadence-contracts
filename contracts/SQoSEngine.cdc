pub contract SQoSEngine {
    pub struct HiddenData {
        // The commitment of hidden data, which is calculated by submitter address, message hash, and a random number
        pub let rawCMT: String;
        pub let fromChain: String;
        pub let msgID: UInt128;

        init(rawCMT: String, fromChain: String, msgID: UInt128) {
            self.rawCMT = rawCMT;
            self.fromChain = fromChain;
            self.msgID = msgID;
        }

        pub fun checkHidden(submitter: Address, messageHash: String, randNumber: UInt32): Bool {
            let rawData = submitter.toBytes().concat(messageHash.decodeHex()).concat(randNumber.toBigEndianBytes());
            let revealHash = String.encodeHex(HashAlgorithm.KECCAK_256.hash(rawData));

            return self.rawCMT == revealHash;
        }
    }
    
    pub resource HiddenReveal {

    }

    pub resource Optimistic {

    }
}