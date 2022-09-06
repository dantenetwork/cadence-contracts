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
    priv var contextRecorder: Context?;

    init() {
        self.contextRecorder = nil;
    }

    access(account) fun setContext(context: Context) {
        self.contextRecorder = context;
    }

    access(account) fun clearContext() {
        self.contextRecorder = nil;
    }
    
    pub fun getContext(): Context? {
        return self.contextRecorder;
    }
}
