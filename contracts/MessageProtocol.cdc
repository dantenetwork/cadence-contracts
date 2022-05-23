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

    pub struct MessageItem {
        pub let n: UInt128;
        pub let t: MsgType;
        pub let v: String;

        pub init(on: UInt128, ot: MsgType, ov: String){
            self.n = on;
            self.t = ot;
            self.v = ov;
        }
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
    }

    pub struct MessagePayload {
        pub let items: [MessageItem]?;
        pub let vecs: [MessageVec]?;

        pub init() {
            self.items = nil;
            self.vecs = nil;
        }

        pub fun addItem(oitem: MessageItem): Bool{
            
        }
    }
}