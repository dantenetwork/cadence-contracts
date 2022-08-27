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
        pub(set) var selectedRouters: [Validator];
        pub let lastSelectTime: UFix64;

        init() {
            self.selectedRouters = [];
            self.lastSelectTime = getCurrentBlock().timestamp;
        }

        pub fun contains(_ identifier: Address): Bool {
            for ele in self.selectedRouters {
                if ele.address == identifier {
                    return true;
                }
            }

            return false;
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

    // Real selection of validators
    priv fun select(): [Validator] {
        // TODO: randomly sampling selection according to credibility and staking
        return self.routers;
    }

    pub fun reSelect(recvAddr: Address) {
        if self.selectedValidators.containsKey(recvAddr) {
            if (getCurrentBlock().timestamp - self.selectedValidators[recvAddr]!.lastSelectTime) > self.timePeriod {
                let newView = SelectView();
                newView.selectedRouters = self.select();
                self.selectedValidators[recvAddr] = newView;
            }
        } else {
            let newView = SelectView();
            newView.selectedRouters = self.select();
            self.selectedValidators[recvAddr] = newView;
        }
    }

    access(account) fun getSelectedValidator(recvAddr: Address): [Validator]{
        self.reSelect(recvAddr: recvAddr);
        return self.selectedValidators[recvAddr]!.selectedRouters;
    }

    access(account) fun isSelected(recvAddr: Address, router: Address): Bool {
        self.reSelect(recvAddr: recvAddr);
        return self.selectedValidators[recvAddr]!.contains(router);
    }

    pub fun getCredibility(router: Address): UFix64? {
        for ele in self.routers {
            if ele.address == router {
                return ele.coe;
            }
        }

        return nil;
    }

    // Update working routers' credibility 
    access(account) fun workingNodesTrail(honest: [Address], evil: [Address]) {
        // TODO
    }

    priv fun do_evil() {

    }

    priv fun do_honest() {

    }
}

