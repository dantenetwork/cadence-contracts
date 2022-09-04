import SettlementContract from "../../contracts/Settlement.cdc";

pub fun main() {
    //let output: [[UFix64]] = [];

    var loops: Int = 0;

    var lastHR = 10.0;
    let honestRst: [UFix64] = [];

    var lastEV = 99.9;
    let evilRst: [UFix64] = [];

    var lastException = 99.9;
    let exceptionRst: [UFix64] = [];

    while loops < 500 {
        let crd = SettlementContract.do_honest(crd: lastHR);
        lastHR = crd;

        let crd2 = SettlementContract.do_evil(crd: lastEV);
        lastEV = crd2;

        let crd3 = SettlementContract.make_exception(crd: lastException, crdWeight: 0.5);
        lastException = crd3;

        if loops % 50 == 0 {
            honestRst.append(crd);
            evilRst.append(lastEV);
            exceptionRst.append(lastException);
            // log(loops);
        }

        loops = loops + 1;
    }

    //output.append(honestRst);
    log("----------------------------------------------------------------")
    log("Simulate doing honest: ");
    log(honestRst);

    //output.append(evilRst);
    log("----------------------------------------------------------------")
    log("Simulate doing evil: ");
    log(evilRst);

    //output.append(exceptionRst);
    log("----------------------------------------------------------------")
    log("Simulate exception: ");
    log(exceptionRst);
}
