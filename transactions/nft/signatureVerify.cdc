import IdentityVerification from 0xf8d6e0586b0a20c7

pub fun main(
    rawData: String, publicKey: String, signature: String, sender: Address
): Bool{
        let isValid = IdentityVerification.basicVerify(
             pubAddr: sender, 
             signatureAlgorithm: SignatureAlgorithm.ECDSA_P256, 
             rawData: rawData.decodeHex(), 
             signature: signature.decodeHex(), 
             hashAlgorithm: HashAlgorithm.SHA3_256   
        );
        
        if !isValid {
            panic("Verify failed!");
        }
        return isValid
}