/* -------------------------------Settlement Contract-----------------------------------
** @This contract is resposible for making evaluation and selection for off-chain routers.
** @Off-Chain routers need to register first before been seleceted as validator node for 
** a concrete `Receiver Resource` on Flow. 
** @The registery need a manually signature to the `account address` of the router and a 
** `nonce` got from `IdentityVerification`. The key pair is related to `keyIndex: 0`. 
** @In the early stage, this contract is mainly for evaluation and selection algorithms, 
** and also, it will be responsible for `staking` and `slashing` in the next.
*/
import IdentityVerification from "./IdentityVerification.cdc";


pub contract SettlementContract {

    pub struct Validator {
        pub let address: Address;
        pub let coe: UFix64;

        init(address: Address) {
            self.address = address;
            self.coe = 0.0;
        }
    }

    pub struct SelectView {
        pub var selectedRouters: [Validator];
        pub let lastSelectTime: UFix64;

        init() {
            self.selectedRouters = [];
            self.lastSelectTime = getCurrentBlock().timestamp;
        }
    }

    priv var routers: [Validator];
    priv let timePeriod: UFix64;

    priv var selectedValidators: {Address: SelectView};

    init() {
        self.routers = [];
        self.timePeriod = 3600.0 * 24.0 * 3.5;
        self.selectedValidators = {};
    }

    pub fun registerRouter(pubAddr: Address, 
                            signatureAlgorithm: SignatureAlgorithm, 
                            signature: [UInt8], 
                            hashAlgorithm: HashAlgorithm) {
        
        if !IdentityVerification.basicVerify(pubAddr: pubAddr,
                                        signatureAlgorithm: signatureAlgorithm,
                                        rawData: [],
                                        signature: signature,
                                        hashAlgorithm: hashAlgorithm) {
            panic("registry signature verification failed!");
        }

        var found = false;
        for ele in self.routers {
            if (ele.address == pubAddr) {
                found = true;
                break;
            }
        }

        if !found {
            self.routers.append(Validator(address: pubAddr));
        }
    }

    pub fun getRegisteredRouters(): [Validator] {
        return self.routers;
    }

    access(account) fun workingNodesTrail() {
        
    }

    pub fun getCredibility(): UFix64 {
        return 0.0;
    }

    priv fun do_evil() {

    }

    priv fun do_honest() {

    }
}

