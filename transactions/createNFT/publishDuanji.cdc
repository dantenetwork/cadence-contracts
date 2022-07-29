import PunstersNFT from "../../examples/Punsters.cdc"
import NonFungibleToken from "../../examples/NonFungibleToken.cdc"

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