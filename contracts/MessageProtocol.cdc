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
        pub let name: String;
        pub let type: MsgType;
        pub let value: AnyStruct;

        access(contract) init(name: String, type: MsgType, value: AnyStruct){
            self.name = name;
            self.type = type;
            self.value = value;
        }

        pub fun toBytes(): [UInt8] {
            var dataBytes: [UInt8] = [];
            dataBytes = dataBytes.concat(self.name.utf8);
            dataBytes = dataBytes.concat([self.type.rawValue]);

            //Encode `AnyStruct` into `[UInt8]`
            switch self.type {
                case MsgType.cdcString:
                    dataBytes = dataBytes.concat(self.value as? String!.utf8);
                    break;
                case MsgType.cdcU8: 
                    dataBytes = dataBytes.concat([self.value as? UInt8!]);
                    break;
                case MsgType.cdcU16: 
                    dataBytes = dataBytes.concat(self.value as? UInt16!.toBigEndianBytes());
                    break;
                case MsgType.cdcU32: 
                    dataBytes = dataBytes.concat(self.value as? UInt32!.toBigEndianBytes());
                    break;
                case MsgType.cdcU64: 
                    dataBytes = dataBytes.concat(self.value as? UInt64!.toBigEndianBytes());
                    break;
                case MsgType.cdcU128: 
                    dataBytes = dataBytes.concat(self.value as? UInt128!.toBigEndianBytes());
                    break;
                case MsgType.cdcI8: 
                    dataBytes = dataBytes.concat(self.value as? Int8!.toBigEndianBytes());
                    break;
                case MsgType.cdcI16: 
                    dataBytes = dataBytes.concat(self.value as? Int16!.toBigEndianBytes());
                    break;
                case MsgType.cdcI32: 
                    dataBytes = dataBytes.concat(self.value as? Int32!.toBigEndianBytes());
                    break;
                case MsgType.cdcI64: 
                    dataBytes = dataBytes.concat(self.value as? Int64!.toBigEndianBytes());
                    break;
                case MsgType.cdcI128: 
                    dataBytes = dataBytes.concat(self.value as? Int128!.toBigEndianBytes());
                    break;
                case MsgType.cdcVecString: 
                    for ele in self.value as? [String]! {
                        dataBytes = dataBytes.concat(ele.utf8);
                    }
                    break;
                case MsgType.cdcVecU8: 
                    dataBytes = dataBytes.concat(self.value as? [UInt8]!);
                    break;
                case MsgType.cdcVecU16: 
                    for ele in self.value as? [UInt16]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecU32: 
                    for ele in self.value as? [UInt32]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecU64: 
                    for ele in self.value as? [UInt64]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecU128: 
                    for ele in self.value as? [UInt128]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI8: 
                    for ele in self.value as? [Int8]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI16: 
                    for ele in self.value as? [Int16]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI32: 
                    for ele in self.value as? [Int32]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI64: 
                    for ele in self.value as? [Int64]! {
                        dataBytes = dataBytes.concat(ele.toBigEndianBytes());
                    }
                    break;
                case MsgType.cdcVecI128: 
                    for ele in self.value as? [Int128]! {
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

        pub fun addItem(item: MessageItem): Bool {
            for ele in self.items {
                if (ele.name == item.name) {
                    return false;
                }
            }

            self.items.append(item);
            return true;
        }

        pub fun getItem(name: String): MessageItem? {
            for ele in self.items {
                if (ele.name == name) {
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

    pub struct SQoS {
        pub let sqosItems: [SQoSItem];

        init() {
            self.sqosItems = [];
        }

        pub fun toBytes(): [UInt8] {
            var dataBytes: [UInt8] = [];

            for ele in self.sqosItems {
                dataBytes = dataBytes.concat(ele.toBytes());
            }

            return dataBytes;
        }
    }

    /// Session
    /// Member@type: 0, C-C(Corss-Chain) call requires call_back; 1, C-C call ignores call_back; 2, C-C call_back;
    pub struct Session {
        pub let id: UInt128;
        pub let type: UInt8;
        pub let callback: String?;
        pub let commitment: [UInt8]?;
        pub let answer: [UInt8]?;

        init(oId: UInt128, oType: UInt8, oCallback: String?, oc: [UInt8]?, oa: [UInt8]?) {
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
            if (nil != self.callback) {
                dataBytes = dataBytes.concat(self.callback!.utf8);
            }
            if (nil != self.commitment) {
                dataBytes = dataBytes.concat(self.commitment!);
            }
            if (nil != self.answer) {
                dataBytes = dataBytes.concat(self.answer!);
            }

            return dataBytes;
        }
    }

    init() {
        self.messageID = 1;
    }

    pub fun createMessageItem(name: String, type: MsgType, value: AnyStruct): MessageItem?{
        switch type {
            case MsgType.cdcString: 
                let v: String = value as? String!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcU8: 
                let v: UInt8 = value as? UInt8!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcU16: 
                let v: UInt16 = value as? UInt16!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcU32: 
                let v: UInt32 = value as? UInt32!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcU64: 
                let v: UInt64 = value as? UInt64!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcU128: 
                let v: UInt128 = value as? UInt128!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcI8: 
                let v: Int8 = value as? Int8!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcI16: 
                let v: Int16 = value as? Int16!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcI32: 
                let v: Int32 = value as? Int32!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcI64: 
                let v: Int64 = value as? Int64!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcI128: 
                let v: Int128 = value as? Int128!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecString: 
                let v: [String] = value as? [String]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecU8: 
                let v: [UInt8] = value as? [UInt8]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecU16: 
                let v: [UInt16] = value as? [UInt16]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecU32: 
                let v: [UInt32] = value as? [UInt32]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecU64: 
                let v: [UInt64] = value as? [UInt64]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecU128: 
                let v: [UInt128] = value as? [UInt128]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecI8: 
                let v: [Int8] = value as? [Int8]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecI16: 
                let v: [Int16] = value as? [Int16]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecI32: 
                let v: [Int32] = value as? [Int32]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecI64: 
                let v: [Int64] = value as? [Int64]!;
                return MessageItem(name: name, type: type, value: value);
            case MsgType.cdcVecI128: 
                let v: [Int128] = value as? [Int128]!;
                return MessageItem(name: name, type: type, value: value);
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
