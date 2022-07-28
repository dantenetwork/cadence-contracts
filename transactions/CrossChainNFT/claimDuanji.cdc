import PunstersNFT from "../../examples/Punsters.cdc"
import Locker from "../../examples/Locker.cdc"

transaction(id: UInt64, answer: String) {

    prepare(acct: AuthAccount) {
        Locker.claimNFT(id: id, answer: answer);
    }

    execute {
        
    }
}