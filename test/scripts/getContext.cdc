import ContextKeeper from "../../contracts/ContextKeeper.cdc"

pub fun main(contexID: String): ContextKeeper.Context? {
    return ContextKeeper.getContext(messageID: messageID);
}
