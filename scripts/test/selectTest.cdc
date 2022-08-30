import SettlementContract from "../../contracts/Settlement.cdc";

pub fun main(): [Address] {
    return SettlementContract.select();
}
