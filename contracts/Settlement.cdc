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
/*
    pub struct selectionInterval {
        pub let lower: UFix64;
        pub let upper: UFix64;
        pub let router: Address;
        pub let crd: UFix64;

        init(router: Address, crd: UFix64, lower: UFix64) {
            self.router = router;
            self.lower = lower;
            self.crd = crd;

            self.upper = lower + crd;
        }

        pub fun contains(point: UInt32): Bool {
            let fPoint = UFix64(point);
            if (self.lower <= fPoint) && (fPoint < self.upper) {
                return true;
            } else {
                return false;
            }
        }
    }
*/

    priv var routers: {Address: Validator};
    priv let timePeriod: UFix64;

    priv var selectedValidators: {Address: SelectView};

    // coefficients
    pub let sys_minCredibility: UFix64;
    pub let sys_maxCredibility: UFix64;
    pub let sys_rangeCredibility: UFix64;
    pub let sys_middleCredbility: UFix64;

    pub let sys_evilStep: UFix64;
    pub let sys_honestStep: UFix64;
    pub let sys_exceptionStep: UFix64;

    // validators
    priv var sys_validatorNumber: UInt32;

    // threshold
    pub let selectCrdLower: UFix64;
    pub let selectCrdUpper: UFix64;
    pub let crd_L_Threshold: UFix64;
    pub let crd_H_Threshold: UFix64;

    init() {
        self.routers = {};
        self.timePeriod = 3600.0 * 24.0 * 3.5;
        self.selectedValidators = {};

        // coefficients
        self.sys_minCredibility = 0.0;
        self.sys_maxCredibility = 100.0;
        self.sys_rangeCredibility = self.sys_maxCredibility - self.sys_minCredibility;
        self.sys_middleCredbility = self.sys_minCredibility + self.sys_rangeCredibility / 2.0;

        
        self.sys_evilStep = 2.0;
        self.sys_honestStep = 1.0;
        self.sys_exceptionStep = 1.0;

        self.selectCrdLower = 0.65;
        self.selectCrdUpper = 0.85;
        self.crd_L_Threshold = 10.0;
        self.crd_H_Threshold = 80.0;

        self.sys_validatorNumber = 7;
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
    pub fun select(): [Address] {
        // TODO: randomly sampling selection according to credibility and staking
        if UInt32(self.routers.length) <= self.sys_validatorNumber {
            return self.routers.keys;
        }

        let selected: [Address] = [];
        let validValidators: [Validator] = [];
        var numberHigh: UInt32 = 0;
        var itvlRange: UFix64 = 0.0;

        for ele in self.routers.values {
            if ele.crd < self.crd_L_Threshold {
                continue;
            }

            validValidators.append(ele);
            itvlRange = itvlRange + ele.crd;

            if (ele.crd >= self.crd_H_Threshold) {
                numberHigh = numberHigh + 1;
            }
        }

        if UInt32(validValidators.length) <= self.sys_validatorNumber {
            for ele in validValidators {
                selected.append(ele.address);
            }

            return selected;
        }
        
        ///////////////////////////////////////////////////////////////////////////////////
        // start selecting
        var crdRatio: UFix64 = UFix64(numberHigh) / UFix64(self.routers.length);
        if crdRatio < self.selectCrdLower {
            crdRatio = self.selectCrdLower;
        } else if crdRatio > self.selectCrdUpper {
            crdRatio = self.selectCrdUpper;
        }

        let crdNumber: UInt32 = UInt32(UFix64(self.sys_validatorNumber) * crdRatio);
        // let randNumber: UInt32 = self.sys_validatorNumber - crdNumber;

        // select according to credibility
        while UInt32(selected.length) < crdNumber {
            var walkedDistance = 0.0;
            let randTwo = self.random2UInt32();
            let ratio =  itvlRange / UFix64(UInt32.max);
            let point1 = UFix64(randTwo[0]) * ratio;
            let point2 = UFix64(randTwo[1]) * ratio;

            let points = [point1, point2];

            if points[1] < points[0] {
                points[0] <-> points[1];
            }

            var passed = 0;
            let selectedIdxs: [Int] = [];
            for idx, ele in validValidators {
                let nextDistance = ele.crd + walkedDistance;
                if (nextDistance > points[passed]) {
                    selected.append(ele.address);
                    selectedIdxs.append(idx);
                    if UInt32(selected.length) >= crdNumber {
                        break;
                    }

                    passed = passed + 1;

                    if passed > 1 {
                        break;
                    }
                    
                    if nextDistance > points[passed] {
                        break;
                    }
                }

                walkedDistance = nextDistance;
            }

            // clear selected validators
            for idxEle in selectedIdxs {
                itvlRange = itvlRange - validValidators[idxEle].crd;
                validValidators.remove(at: idxEle);
            }
        }

        // select randomly
        while UInt32(selected.length) < self.sys_validatorNumber {
            let randTwo = self.random2UInt32();
            for randIdx in randTwo {
                let idx = randIdx % UInt32(validValidators.length);
                selected.append(validValidators[idx].address);
                validValidators.remove(at: idx);
                if UInt32(selected.length) >= self.sys_validatorNumber {
                    break;
                }
            }
        }

        return selected;
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

        let credibility_value: UFix64 = crd - self.sys_evilStep * (crd - self.sys_minCredibility) / self.sys_rangeCredibility;
        return credibility_value;
    }

    pub fun do_honest(crd: UFix64): UFix64 {
        var credibility_value: UFix64 = 0.0;

        if crd < self.sys_middleCredbility {
            credibility_value = crd + self.sys_honestStep
                                        * (crd - self.sys_minCredibility)
                                        / self.sys_rangeCredibility;
        } else {
            credibility_value = crd + self.sys_honestStep
                                        * (self.sys_maxCredibility - crd)
                                        / self.sys_rangeCredibility;
        }

        return credibility_value;
    }

    pub fun make_exception(crd: UFix64, crdWeight: UFix64): UFix64 {
        let credibility_value: UFix64 = crd - self.sys_exceptionStep * (crd - self.sys_minCredibility)
                            / self.sys_rangeCredibility
                            * (1.0 - crdWeight);

        return credibility_value;
    }

    pub fun random2UInt32(): [UInt32; 2] {
        let tmp64 = unsafeRandom();

        let lower32: UInt32 = UInt32(tmp64 & 0x00000000FFFFFFFF);
        let high32: UInt32 = UInt32(tmp64 >> 32);

        return [high32, lower32];
    }

    // Test funcions. To be deleted

}

