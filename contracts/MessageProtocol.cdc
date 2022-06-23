pub contract MessageProtocol {
    /// Message Payload Defination
    pub enum MsgType: UInt8 {
        pub case cdcString
        pub case cdcU8
        pub case cdcU16
        pub case cdcU32
        pub case cdcU64
        pub case cdcU128
        pub case cdcI8
        pub case cdcI16
        pub case cdcI32
        pub case cdcI64
        pub case cdcI128
        pub case cdcVecString
        pub case cdcVecU8
        pub case cdcVecU16
        pub case cdcVecU32
        pub case cdcVecU64
        pub case cdcVecU128
        pub case cdcVecI8
        pub case cdcVecI16
        pub case cdcVecI32
        pub case cdcVecI64
        pub case cdcVecI128
    }

    // This is not supported yet
    // pub struct interface Equatable {
    //     pub fun equals(_ other: {Equatable}): Bool
    // }

    pub struct MessageItem {
        pub let n: UInt128;
        pub let t: MsgType;
        pub let v: AnyStruct;

        pub init(on: UInt128, ot: MsgType, ov: AnyStruct){
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

    pub struct MessagePayload {
        pub let items: [MessageItem];

        pub init() {
            self.items = [];
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
    }

    /// SQoS
    pub enum SQoSType: UInt8 {
        pub case Reveal
        pub case Challenge
        pub case Threshold
        pub case Priority
        pub case ExceptionRollback
        pub case SelectionDelay
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