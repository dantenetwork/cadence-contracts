import PunstersNFT from "../../examples/Punsters.cdc"
import NonFungibleToken from "../../examples/NonFungibleToken.cdc"
import StarRealm from "../../examples/StarRealm.cdc"

transaction (description: String, ipfsURL: String) {

  prepare(acct: AuthAccount) {

      let punster <- PunstersNFT.registerPunster(addr: acct.address, 
                                                description: "Punster: ".concat(acct.address.toString()).concat(". ").concat(description), 
                                                ipfsURL: ipfsURL);

      acct.save(<-punster, to: PunstersNFT.PunsterStoragePath);
      acct.link<&{PunstersNFT.IPunsterPublic}>(PunstersNFT.IPunsterPublicPath, target: PunstersNFT.PunsterStoragePath);
      
      // if a punster is registered, clear the `StarRealm.DockerPublicPath` first.
      acct.unlink(StarRealm.DockerPublicPath);
      acct.link<&{StarRealm.StarDocker}>(StarRealm.DockerPublicPath, target: PunstersNFT.PunsterStoragePath);

      let starPort <- StarRealm.createStarPort();
      // don't link `starPort` if punster exists
      acct.save(<- starPort, to: StarRealm.PortStoragePath);
  }

  execute {
    
  }
}
