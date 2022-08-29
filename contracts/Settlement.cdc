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
        pub(set) var crd: UFix64;

        init(address: Address) {
            self.address = address;
            self.crd = 10.0;
        }
    }

    pub struct SelectView {
        pub(set) var selectedRouters: [Address];
        pub let lastSelectTime: UFix64;

        init() {
            self.selectedRouters = [];
            self.lastSelectTime = getCurrentBlock().timestamp;
        }

        pub fun contains(_ identifier: Address): Bool {
            return self.selectedRouters.contains(identifier);
        }
    }

    priv var routers: {Address: Validator};
    priv let timePeriod: UFix64;

    priv var selectedValidators: {Address: SelectView};

    // coefficients
    pub let minCredibility: UFix64;
    pub let maxCredibility: UFix64;
    pub let rangeCredibility: UFix64;
    pub let middleCredbility: UFix64;

    pub let evilStep: UFix64;
    pub let honestStep: UFix64;
    pub let exceptionStep: UFix64;


    init() {
        self.routers = {};
        self.timePeriod = 3600.0 * 24.0 * 3.5;
        self.selectedValidators = {};

        // coefficients
        self.minCredibility = 0.0;
        self.maxCredibility = 100.0;
        self.rangeCredibility = self.maxCredibility - self.minCredibility;
        self.middleCredbility = self.minCredibility + self.rangeCredibility / 2.0;

        
        self.evilStep = 2.0;
        self.honestStep = 1.0;
        self.exceptionStep = 1.0;
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

        if !self.routers.containsKey(pubAddr) {
            self.routers[pubAddr] = Validator(address: pubAddr);
        }
    }

    pub fun getRegisteredRouters(): [Validator] {
        return self.routers.values;
    }

    // Real selection of validators
    priv fun select(): [Address] {
        // TODO: randomly sampling selection according to credibility and staking
        return self.routers.keys;
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

    access(account) fun getSelectedValidator(recvAddr: Address): [Address]{
        self.reSelect(recvAddr: recvAddr);
        return self.selectedValidators[recvAddr]!.selectedRouters;
    }

    access(account) fun isSelected(recvAddr: Address, router: Address): Bool {
        self.reSelect(recvAddr: recvAddr);
        return self.selectedValidators[recvAddr]!.contains(router);
    }

    pub fun getCredibility(router: Address): UFix64? {
        if let validator = self.routers[router] {
            return validator.crd;
        }

        return nil;
    }

    // Update working routers' credibility 
    access(account) fun workingNodesTrail(honest: [Address], evil: [Address], exception: {Address: UFix64}) {
        // honest
        for ele in honest {
            if let validatorRef: &SettlementContract.Validator = &self.routers[ele] as &SettlementContract.Validator? {
                validatorRef.crd = self.do_honest(crd: validatorRef.crd);
            }
        }

        // evil
        for ele in evil {
            if let validatorRef: &SettlementContract.Validator = &self.routers[ele] as &SettlementContract.Validator? {
                validatorRef.crd = self.do_evil(crd: validatorRef.crd);
            }
        }

        //exception
        for ele in exception.keys {
            if let validatorRef: &SettlementContract.Validator = &self.routers[ele] as &SettlementContract.Validator? {
                validatorRef.crd = self.make_exception(crd: validatorRef.crd, crdWeight: exception[ele]!);
            }
        }
    }

    pub fun do_evil(crd: UFix64): UFix64 {

        let credibility_value: UFix64 = crd - self.evilStep * (crd - self.minCredibility) / self.rangeCredibility;
        return credibility_value;
    }

    pub fun do_honest(crd: UFix64): UFix64 {
        var credibility_value: UFix64 = 0.0;

        if crd < self.middleCredbility {
            credibility_value = crd + self.honestStep
                                        * (crd - self.minCredibility)
                                        / self.rangeCredibility;
        } else {
            credibility_value = crd + self.honestStep
                                        * (self.maxCredibility - crd)
                                        / self.rangeCredibility;
        }

        return credibility_value;
    }

    pub fun make_exception(crd: UFix64, crdWeight: UFix64): UFix64 {
        let credibility_value: UFix64 = crd - self.exceptionStep * (crd - self.minCredibility)
                            / self.rangeCredibility
                            * (1.0 - crdWeight);

        return credibility_value;
    }
}

