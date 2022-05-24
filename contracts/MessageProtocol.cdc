pub contract MessageProtocol {
    /// Message Payload Defination
    pub enum MsgType: UInt8 {
        pub case InkString
        pub case InkU8
        pub case InkU16
        pub case InkU32
        pub case InkU64
        pub case InkU128
        pub case InkI8
        pub case InkI16
        pub case InkI32
        pub case InkI64
        pub case InkI128
        pub case UserData
    }

    // This is not supported yet
    // pub struct interface Equatable {
    //     pub fun equals(_ other: {Equatable}): Bool
    // }

    pub struct MessageItem {
        pub let n: UInt128;
        pub let t: MsgType;
        pub let v: String;

        pub init(on: UInt128, ot: MsgType, ov: String){
            self.n = on;
            self.t = ot;
            self.v = ov;
        }

        // pub fun equals(_ other: {Equatable}): Bool {
        //     if let otherMI = other as? MessageItem {
        //         return self.n == otherMI.n;
        //     }
        //     else{
        //         return false;
        //     }
        // }
    }

    pub struct MessageVec {
        pub let n: UInt128;
        pub let t: MsgType;
        pub let v: [String];

        pub init(on: UInt128, ot: MsgType){
            self.n = on;
            self.t = ot;
            self.v = [];
        }

        // pub fun equals(_ other: {Equatable}): Bool {
        //     if let otherMV = other as? MessageVec {
        //         return self.n == otherMV.n;
        //     }
        //     else{
        //         return false;
        //     }
        // }
    }

    pub struct MessagePayload {
        pub let items: [MessageItem];
        pub let vecs: [MessageVec];

        pub init() {
            self.items = [];
            self.vecs = [];
        }

        pub fun addItem(omi: MessageItem): Bool {
            for ele in self.items {
                if (ele.n == omi.n) {
                    return false;
                }
            }

            self.items.append(omi);
            return true;
        }

        pub fun getItem(_ id: UInt128): MessageItem? {
            for ele in self.items {
                if (ele.n == id) {
                    return ele;
                }
            }
            return nil;
        }

        pub fun addVec(omv: MessageVec): Bool {
            for ele in self.vecs {
                if (ele.n == omv.n){
                    return false;
                }
            }

            self.vecs.append(omv);
            return true;
        }

        pub fun getVec(_ id: UInt128): MessageVec? {
            for ele in self.vecs {
                if (ele.n == id) {
                    return ele;
                }
            }
            return nil;
        }
    }


    /// SQoS
    pub enum SQoSType: UInt8 {
        pub case Reveal
        pub case Challenge
        pub case Threshold
        pub case Priority
        pub case ExceptionRollback
        pub case Anonymous
        pub case Identity
        pub case Isolation
        pub case CrossVerify
    }

    pub struct SQoSItem {
        pub let t: SQoSType;
        pub let v: String;

        init(type: SQoSType, value: String){
            self.t = type;
            self.v = value;
        }
    }
}