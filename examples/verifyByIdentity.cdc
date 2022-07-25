import IdentityVerification from "../contracts/IdentityVerification.cdc"

transaction (rawData: String, signature: String) {

    prepare(acct: AuthAccount) {
        let isValid = IdentityVerification.basicVerify(
             pubAddr: acct.address, 
             signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, 
             rawData: rawData.decodeHex(), 
             signature: signature.decodeHex(), 
             hashAlgorithm: HashAlgorithm.SHA3_256   
        );
        
        if !isValid {
            panic("Verify failed!");
        }
    }

    execute {
        
    }
}
