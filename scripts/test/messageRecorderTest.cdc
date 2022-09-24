import MessageRecorder from "../../contracts/MessageRecorder.cdc"

pub fun main() {
    log("Flow: ");
    log(MessageRecorder.getNextMessageID(chain: "Flow"));
    log(MessageRecorder.getID(chain: "Flow"));
    log("PlatON: ");
    log(MessageRecorder.getNextMessageID(chain: "PlatON"));
    log(MessageRecorder.getID(chain: "PlatON"));
    log("Rinkeby: ");
    log(MessageRecorder.getNextMessageID(chain: "Rinkeby"));
    log(MessageRecorder.getNextMessageID(chain: "Rinkeby"));
    log(MessageRecorder.getNextMessageID(chain: "Rinkeby"));
    log(MessageRecorder.getID(chain: "Rinkeby"));
}