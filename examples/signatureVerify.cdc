
transaction {

  prepare(acct: AuthAccount) {
    let pk = PublicKey(publicKey: "bb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025".decodeHex(), 
                                signatureAlgorithm: SignatureAlgorithm.ECDSA_P256);
    
    let isValid = pk.verify(signature: "cba9773c0dd53e82cfdac096a3a49df60c64a156ddecc04e623110892b0be8a546202eb3cac331e861ea8902119cc8132471840bf0155f8c1053326804e06a2d".decodeHex(),
                          signedData: "Hello Nika".utf8,
                          domainSeparationTag: "",
                          hashAlgorithm: HashAlgorithm.SHA3_256);
    log(isValid);
  }

  execute {
    
  }
}
