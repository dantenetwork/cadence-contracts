
transaction {

  prepare(acct: AuthAccount) {
    let pk = PublicKey(publicKey: "bb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025".decodeHex(), 
                                signatureAlgorithm: SignatureAlgorithm.ECDSA_P256);
    
    let isValid = pk.verify(signature: "ff8cf785b77367c4606b1c37e0147bf094cdf735301718fa533865026eaa654f15cc3ba111e1d8873958584f9cd6153ef642783a745de714520249886dbf0a0f".decodeHex(),
                          signedData: "f8d6e0586b0a20c70094641361b92573f46947c203d47820679efed581e155af07528e78fca08374b5".utf8,
                          domainSeparationTag: "",
                          hashAlgorithm: HashAlgorithm.SHA3_256);
    log(isValid);
    if !isValid {
      panic("verify failed!");
    }
  }

  execute {
    
  }
}
