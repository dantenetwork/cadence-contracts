import SQoSEngine from "../../contracts/SQoSEngine.cdc"

pub fun main(submitter: Address, messageHash: String, randNumber: UInt32): String {
    return String.encodeHex(submitter.toBytes().concat(messageHash.decodeHex()).concat(randNumber.toBigEndianBytes()));
}  