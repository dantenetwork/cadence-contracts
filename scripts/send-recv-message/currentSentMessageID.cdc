import MessageRecorder from "../../contracts/MessageRecorder.cdc"

pub fun main(chain: String): UInt128{
    return MessageRecorder.getID(chain: chain);
}
