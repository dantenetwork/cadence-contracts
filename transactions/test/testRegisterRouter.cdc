import SettlementContract from "../../contracts/Settlement.cdc";

transaction(addrCount: UInt64){
    let signer: AuthAccount;

    prepare(signer: AuthAccount){
        self.signer = signer
    }

    execute {
        var addr: UInt64 = 0x01;
        let routers: [Address] = [];
        while addr < addrCount {
            routers.append(Address(addr));
            addr = addr + 1;
        }

        SettlementContract.testRegisterRouters(routers: routers);
    }
}
