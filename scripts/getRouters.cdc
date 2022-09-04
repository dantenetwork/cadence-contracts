import SettlementContract from "../contracts/Settlement.cdc";

pub fun main(): [SettlementContract.Validator] {
    return SettlementContract.getRegisteredRouters();
}
