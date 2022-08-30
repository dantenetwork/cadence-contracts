import SettlementContract from "../../contracts/Settlement.cdc";

pub struct SelectStatistic {
    pub let router: Address;
    pub let crd: UFix64;
    pub(set) var selected: UInt32;

    init(router: Address, crd: UFix64) {
        self.router = router;
        self.crd = crd;
        self.selected = 0;
    }
}

pub fun main() {
    var addr: UInt64 = 0x01;
    let routers: [Address] = [];
    while addr < 100 {
        routers.append(Address(addr));
        addr = addr + 1;
    }

    SettlementContract.testRegisterRouters(routers: routers);

    let validators = SettlementContract.getRegisteredRouters();

    for ele in validators {
        
    }
}