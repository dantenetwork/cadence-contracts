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

        access(contract) init(on: UInt128, ot: MsgType, ov: AnyStruct){
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

    /// Session
    /// Member@type: 0, C-C(Corss-Chain) call requires call_back; 1, C-C call ignores call_back; 2, C-C call_back;
    pub struct Session {
        pub let id: UInt32;
        pub let type: UInt8;
        pub let callback: String;

        //TODO: commitment

        init(oId: UInt32, oType: UInt8, oCallback: String) {
            self.id = oId;
            self.type = oType;
            self.callback = oCallback;
        }
    }

    pub fun createMessageItem(ocn: UInt128, oct: MsgType, ocv: AnyStruct): MessageItem?{
        switch oct {
            case MsgType.cdcString: 
                let v: String = ocv as? String!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcU8: 
                let v: UInt8 = ocv as? UInt8!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcU16: 
                let v: UInt16 = ocv as? UInt16!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcU32: 
                let v: UInt32 = ocv as? UInt32!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcU64: 
                let v: UInt64 = ocv as? UInt64!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcU128: 
                let v: UInt128 = ocv as? UInt128!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcI8: 
                let v: Int8 = ocv as? Int8!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcI16: 
                let v: Int16 = ocv as? Int16!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcI32: 
                let v: Int32 = ocv as? Int32!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcI64: 
                let v: Int64 = ocv as? Int64!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcI128: 
                let v: Int128 = ocv as? Int128!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecString: 
                let v: [String] = ocv as? [String]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecU8: 
                let v: [UInt8] = ocv as? [UInt8]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecU16: 
                let v: [UInt16] = ocv as? [UInt16]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecU32: 
                let v: [UInt32] = ocv as? [UInt32]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecU64: 
                let v: [UInt64] = ocv as? [UInt64]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecU128: 
                let v: [UInt128] = ocv as? [UInt128]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecI8: 
                let v: [Int8] = ocv as? [Int8]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecI16: 
                let v: [Int16] = ocv as? [Int16]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecI32: 
                let v: [Int32] = ocv as? [Int32]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecI64: 
                let v: [Int64] = ocv as? [Int64]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            case MsgType.cdcVecI128: 
                let v: [Int128] = ocv as? [Int128]!;
                return MessageItem(on: ocn, ot: oct, ov: ocv);
            default:
                return nil;
        }
    }
}
