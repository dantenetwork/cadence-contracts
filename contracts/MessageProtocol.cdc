pub contract MessageProtocol {
    access(contract) var messageID: UInt128;
    
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

        pub fun toBytes(): [UInt8] {
            var dataBytes: [UInt8] = [];
            dataBytes = dataBytes.concat(self.n.toBigEndianBytes());
            dataBytes = dataBytes.concat([self.t as? UInt8!]);

            //Encode `AnyStruct` into `[UInt8]`
            switch self.t {
                case MsgType.cdcString:
                    dataBytes = dataBytes.concat(self.v as? String!.utf8);
                    break;
                case MsgType.cdcU8: 
                    dataBytes = dataBytes.concat([self.v as? UInt8!]);
                    break;
                case MsgType.cdcU16: 
                    dataBytes = dataBytes.concat(self.v as? UInt16!.toBigEndianBytes());
                    break;
                case MsgType.cdcU32: 
                    dataBytes = dataBytes.concat(self.v as? UInt32!.toBigEndianBytes());
                    break;
                case MsgType.cdcU64: 
                    dataBytes = dataBytes.concat(self.v as? UInt64!.toBigEndianBytes());
                    break;
                case MsgType.cdcU128: 
                    dataBytes = dataBytes.concat(self.v as? UInt128!.toBigEndianBytes());
                    break;
                case MsgType.cdcI8: 
                    dataBytes = dataBytes.concat(self.v as? Int8!.toBigEndianBytes());
                    break;
                case MsgType.cdcI16: 
                    dataBytes = dataBytes.concat(self.v as? Int16!.toBigEndianBytes());
                    break;
                case MsgType.cdcI32: 
                    dataBytes = dataBytes.concat(self.v as? Int32!.toBigEndianBytes());
                    break;
                case MsgType.cdcI64: 
                    dataBytes = dataBytes.concat(self.v as? Int64!.toBigEndianBytes());
                    break;
                case MsgType.cdcI128: 
                    dataBytes = dataBytes.concat(self.v as? Int128!.toBigEndianBytes());
                    break;
                case MsgType.cdcVecString: 
                    for ele in self.v as? [String]! {
                        dataBytes = dataBytes.concat(ele.utf8);
                    }
                    break;
                case MsgType.cdcVecU8: 
                    dataBytes = dataBytes.concat(self.v as? [UInt8]!);
                    break;
                case MsgType.cdcVecU16: 
                    for ele in self.v as? [UInt16]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecU32: 
                    for ele in self.v as? [UInt32]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecU64: 
                    for ele in self.v as? [UInt64]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecU128: 
                    for ele in self.v as? [UInt128]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI8: 
                    for ele in self.v as? [Int8]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI16: 
                    for ele in self.v as? [Int16]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI32: 
                    for ele in self.v as? [Int32]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI64: 
                    for ele in self.v as? [Int64]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI128: 
                    for ele in self.v as? [Int128]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
            }

            return dataBytes;
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

        pub fun toBytes(): [UInt8] {
            var dataBytes: [UInt8] = [];

            //iterate `self.items` to build the encoding bytes
            for ele in self.items {
                dataBytes = dataBytes.concat(ele.toBytes());
            }

            return dataBytes;
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

        pub fun toBytes(): [UInt8] {
            var dataBytes: [UInt8] = [];
            dataBytes = dataBytes.concat([self.t as? UInt8!]);
            dataBytes = dataBytes.concat(self.v.utf8);

            return dataBytes;
        }
    }

    /// Session
    /// Member@type: 0, C-C(Corss-Chain) call requires call_back; 1, C-C call ignores call_back; 2, C-C call_back;
    pub struct Session {
        pub let id: UInt32;
        pub let type: UInt8;
        pub let callback: String;
        pub let commitment: [UInt8]?;
        pub let answer: [UInt8]?;

        init(oId: UInt32, oType: UInt8, oCallback: String, oc: [UInt8]?, oa: [UInt8]?) {
            self.id = oId;
            self.type = oType;
            self.callback = oCallback;
            self.commitment = oc;
            self.answer = oa;
        }

        pub fun toBytes(): [UInt8] {
            var dataBytes: [UInt8] = [];
            dataBytes = dataBytes.concat(self.id.toBigEndianBytes());
            dataBytes = dataBytes.concat([self.type]);
            dataBytes = dataBytes.concat(self.callback.utf8);
            if (nil != commitment) {
                dataBytes = dataBytes.concat(commitment!);
            }
            if (nil != answer) {
                dataBytes = dataBytes.concat(answer!);
            }

            return dataBytes;
        }
    }

    init() {
        self.messageID = 0;
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

    pub fun getNextMessageID(): UInt128 {
        let id = self.messageID;
        self.messageID = self.messageID + 1;
        return id;
    }
}
