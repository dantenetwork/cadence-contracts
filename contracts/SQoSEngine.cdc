pub contract SQoSEngine {
    pub struct RevealData {
        pub let messageHash: String;
        pub let randNumber: UInt32;

        init(messageHash: String, randNumber: UInt32) {
            self.messageHash = messageHash;
            self.randNumber = randNumber;
        }
    }
    
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

        pub fun checkReveal(submitter: Address, rvData: RevealData): Bool {
            let rawData = submitter.toBytes().concat(rvData.messageHash.decodeHex()).concat(rvData.randNumber.toBigEndianBytes());
            let revealHash = String.encodeHex(HashAlgorithm.KECCAK_256.hash(rawData));

            return self.rawCMT == revealHash;
        }
    }

    pub struct HRRecord {
        pub let hdData: HiddenData;
        // pub var rvData: RevealData?;

        init(hdData: HiddenData) {
            self.hdData = hdData;
            // self.rvData = nil;
        }
    }
    
    pub resource HiddenReveal {
        // outter key: fromChain + msgID.toString()
        // inner key: submitter address
        pub let hrRecord: {String: {Address: HRRecord}};
        priv var defaultCopyCount: Int;

        init(defaultCopyCount: Int) {
            self.hrRecord = {};
            self.defaultCopyCount = defaultCopyCount;
        }

        pub fun submitHidden(submitter: Address, hidden: HiddenData) {
            let outterKey = hidden.fromChain.concat(hidden.msgID.toString());

            if self.hrRecord.containsKey(outterKey) {
                if self.hrRecord[outterKey]!.containsKey(submitter) {
                    panic("Duplicate submission!");
                } else {
                    self.hrRecord[outterKey]!.insert(key: submitter, HRRecord(hdData: hidden));
                }
            } else {
                self.hrRecord[outterKey] = {submitter: HRRecord(hdData: hidden)};
            }
        }

        pub fun submitReveal(submitter: Address, fromChain: String, msgID: UInt128, rvData: RevealData): Bool {
            let outterKey = fromChain.concat(msgID.toString());

            if let hrRecordsRef: &{Address: HRRecord} = &self.hrRecord[outterKey] as &{Address: HRRecord}? {
                if hrRecordsRef.length < self.defaultCopyCount {
                    // TODO: make slashing to the submitter
                    panic("Error: not enough hidden data submitted!");
                }
                
                if let submissionRef: &HRRecord = &hrRecordsRef[submitter] as &HRRecord? {
                    return submissionRef.hdData.checkReveal(submitter: submitter, rvData: rvData);
                } else {
                    panic("None related hidden data found! No inner key!");
                }
            } else {
                panic("None related hidden data found! No outter key!");
            }

            return false;
        }

        access(account) fun setDefaultCopyCount(defaultCopyCount: Int) {
            self.defaultCopyCount = defaultCopyCount;
        }
    }

    pub resource Optimistic {

    }
}