import PunstersNFT from "../../examples/Punsters.cdc"
import Locker from "../../examples/Locker.cdc"
import StarRealm from "../../examples/StarRealm.cdc"

transaction(hashValue: String) {

    prepare(acct: AuthAccount) {
        let punster <- acct.load<@PunstersNFT.Collection>(from: PunstersNFT.PunsterStoragePath)!;

        let punsterID = punster.id;

        Locker.sendCrossChainNFT(transferToken: <- punster, 
                                signerAddress: acct.address, 
                                id: punsterID, 
                                owner: acct.address.toString(), 
                                hashValue: hashValue);

        acct.unlink(StarRealm.DockerPublicPath);
        acct.unlink(PunstersNFT.IPunsterPublicPath);
        acct.link<&{StarRealm.StarDocker}>(StarRealm.DockerPublicPath, target: StarRealm.PortStoragePath);
    }

    execute {
        
    }
}
