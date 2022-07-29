import PunstersNFT from 0x1a478a7149935b63
import NonFungibleToken from 0x1a478a7149935b63

transaction(description: String, ipfsURL: String) {

  prepare(acct: AuthAccount) {

      if let punsterRef = acct.borrow<&PunstersNFT.Collection>(from: PunstersNFT.PunsterStoragePath) {
        punsterRef.publishDuanji(description: "Duanji from ".concat(acct.address.toString()).concat(". ").concat(description), 
                                ipfsURL: ipfsURL);
      }
  }

  execute {
    
  }
}