import StarLocker from "../contracts/StarLocker.cdc"

pub fun main(): {String: [UInt64]}{
    return StarLocker.getLockedNFTs();
}