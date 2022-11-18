import SettlementContract from "../../contracts/Settlement.cdc"

pub fun main(): {Address: SettlementContract.Validator} {
    return SettlementContract.getValidatorInfor();
}