import IdentityVerification from "../contracts/IdentityVerification.cdc"

pub fun main(): UInt128 {
    return IdentityVerification.getNonce(pubAddr: 0xf8d6e0586b0a20c7);
}