
pub contract IdentityVerification {
    priv var nonce: {Address: UInt128};

    init() {
        self.nonce = {};
    }

    // Verify whether both the `pubAddr` and `rawData` are valid
    // So the `signature` is composited with: `pubAddr` + `self.nonce` + `rawData`
    pub fun basicVerify(pubAddr: Address, signatureAlgorithm: SignatureAlgorithm, rawData: [UInt8], signature: [UInt8], hashAlgorithm: HashAlgorithm): Bool {
        var nonceV: UInt128 = 0;
        if let val = self.nonce[pubAddr] {
            nonceV = val + 1;
        }
        
        let pubAcct = getAccount(pubAddr);
        let pk = PublicKey(publicKey: pubAcct.keys.get(keyIndex: 0)!.publicKey.publicKey, 
                            signatureAlgorithm: signatureAlgorithm);

        let originData: [UInt8] = pubAddr.toBytes().concat(nonceV.toBigEndianBytes()).concat(rawData);
        log(String.encodeHex(originData))
        log(String.encodeHex(signature))

        if (pk.verify(signature: signature,
                        signedData: String.encodeHex(originData).utf8,
                        domainSeparationTag: "",
                        hashAlgorithm: hashAlgorithm)) {
            self.nonce[pubAddr] = nonceV;
            return true;
        } else {
            return false;
        }
    }

    pub fun getNonce(pubAddr: Address): UInt128 {
        if let val = self.nonce[pubAddr] {
            return val + 1;
        } else {
            return 0;
        }
    }
}
