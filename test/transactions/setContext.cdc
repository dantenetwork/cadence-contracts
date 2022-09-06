import ContextKeeper from "../../contracts/ContextKeeper.cdc"
import MessageProtocol from "../../contracts/MessageProtocol.cdc"

transaction(contextID: String){
    prepare(signer: AuthAccount){

    }

    execute {
        let sqos = MessageProtocol.SQoS();
        let session = MessageProtocol.Session(oId: 1, 
                                                oType: 1, 
                                                oCallback: nil, 
                                                oc: nil, 
                                                oa: nil);

        ContextKeeper.setContext(contextID: contextID, context: ContextKeeper.Context(id: 0,
                                                                                        fromChain: "nika",
                                                                                        sender: [],
                                                                                        signer: [],
                                                                                        sqos: sqos,
                                                                                        session: session));

    }
}
