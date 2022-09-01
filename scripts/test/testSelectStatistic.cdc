import SettlementContract from "../../contracts/Settlement.cdc";

pub struct SelectStatistic {
    pub let router: Address;
    pub let crd: UFix64;
    pub var selected: UInt32;

    init(router: Address, crd: UFix64) {
        self.router = router;
        self.crd = crd;
        self.selected = 0;
    }

    pub fun addSelected() {
        self.selected = self.selected + 1;
    }
}

pub fun main(): [[UFix64; 2]]{
    /*
    var addr: UInt64 = 0x01;
    let routers: [Address] = [];
    while addr < 100 {
        routers.append(Address(addr));
        addr = addr + 1;
    }
    
    SettlementContract.testRegisterRouters(routers: routers);
    */

    let validators = SettlementContract.getRegisteredRouters();

    let staticHolder: {Address: SelectStatistic} = {};

    var sumCrd: UFix64 = 0.0;
    for ele in validators {
        staticHolder[ele.address] = SelectStatistic(router: ele.address, crd: ele.crd);
        sumCrd = sumCrd + ele.crd;
    }

    var loops = 0;
    while loops < 300 {
        let slctedValidators = SettlementContract.select();

        for ele in slctedValidators {
            staticHolder[ele]!.addSelected();
        }

        loops = loops + 1;
    }

    let rst: [[UFix64; 2]] = [];
    for ele in staticHolder.values {
        let c = ele.crd / sumCrd;
        let s = UFix64(ele.selected) / 300.0 / 7.0;

        rst.append([c, s]);
    }

    return rst;
}