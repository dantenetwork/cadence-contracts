import PunstersNFT from "../../examples/Punsters.cdc"
import Locker from "../../examples/Locker.cdc"

transaction(hashValue: String, owner: String, duanjiID: UInt64) {

    prepare(acct: AuthAccount) {
        let punsterRef = acct.borrow<&PunstersNFT.Collection>(from: PunstersNFT.PunsterStoragePath)!;

        let duanji <- punsterRef.withdraw(withdrawID: duanjiID);

        Locker.sendCrossChainNFT(transferToken: <- duanji, 
                                signerAddress: acct.address, 
                                id: duanjiID, 
                                owner: owner, 
                                hashValue: hashValue);
    }

    execute {
        
    }
}
