import MessageProtocol from "./MessageProtocol.cdc"

pub contract ContextKeeper {

    pub struct Context {
        pub let id: UInt128;
        pub let fromChain: String;
        pub let sender: [UInt8];
        pub let signer: [UInt8];
        pub let sqos: MessageProtocol.SQoS;
        pub let session: MessageProtocol.Session;

        init(id: UInt128,
                fromChain: String,
                sender: [UInt8],
                signer: [UInt8],
                sqos: MessageProtocol.SQoS,
                session: MessageProtocol.Session) {
            self.id = id;
            self.fromChain = fromChain;
            self.sender = sender;
            self.signer = signer;
            self.sqos = sqos;
            self.session = session;
        }
    }

    // the key is `fromChain`.concat(id) 
    priv let contexRecorder: {String: Context};

    init() {
        self.contexRecorder = {};
    }

    access(account) fun setContext(contextID: String, context: Context) {
        self.contexRecorder[contextID] = context;
    }

    access(account) fun clearContext(contextID: String) {
        self.contexRecorder.remove(key: contextID);
    }
    
    pub fun getContext(contextID: String): Context? {
        return self.contexRecorder[contextID];
    }
}
