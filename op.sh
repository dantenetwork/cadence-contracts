pm2 status

pm2 start client/crosschain/crossChainSync.js —name FlowCrossChain
flow project deploy --update -n testnet

flow project deploy --update

flow accounts create --key 81262aa27f1630ccf1293300e8e1d9a6ba542dffa796b860d53873867175e9d31bd7b7581d2f200f9c3dfdbc10ae912ff036946981e3d8996a14f186d20e3e2f

# transfer Flow Token
flow transactions send ./transactions/test/transferFlow.cdc 100.0 0x01cf0e2f2f715450


flow signatures generate "hello nika" --signer emulator-account

flow transactions send ./transactions/verifyByIdentity.cdc "633506677220b0e1c71447ebf1c4b050d44552383501ffdfcb1b46c7a71484f1" "5b150258301bd5847e753c37b76bc97178a106ed15edd51683001abb90c0f43a2ca5d6108fc235cb6485f115c2a2e0fee800be6900f35df7cea6733ef9feec87"

flow scripts execute ./examples/recvCoreDataCreate.cdc 

flow transactions send ./examples/signatureVerify.cdc

flow scripts execute ./examples/getNonce.cdc

flow signatures verify "hello nika" "b8c91eb13af6d08e357de09fac0b500e93e77bf74ca2a474742b67c26ba5eabf1355ca1ac6bdfb45c741f7d8a49201a6b9ab918f9387d1d2594b455c3f3d264d" 0xbb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025

flow transactions send ./transactions/verifyRecvMsgTest.cdc "7a4152dcbcef2d1db8a5754913105a3486b5a651a7cad2f6f7025c5d0414ec014e68bd7323a9c1c165071a5721be16bf3d26b8f5495a8d44b3759d4f61f288c1"


flow transactions send ./transactions/createNFT/registerPunster.cdc "I'm punster Alice!" "Punster Alice's ipfs url"

flow transactions send ./transactions/createNFT/publishDuanji.cdc "I found the dog is so funny!" "ipfs uri 2 is defined"

flow transactions send ./transactions/CrossChainNFT/sendPunster2Opensea.cdc "044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217"

flow transactions send ./transactions/CrossChainNFT/sendDuanji2Opensea.cdc "044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217" 1

flow transactions send ./transactions/CrossChainNFT/claimDuanji.cdc 1 "randomNumber"

flow transactions send ./transactions/CrossChainNFT/claimPunster.cdc 1 "randomNumber"

# Testnet
flow transactions send ./transactions/createNFT/registerPunster.cdc "I'm punster" "https://raw.githubusercontent.com/wuyahuang/opensea/main/1" --signer testnet-Bob -n testnet

flow scripts execute ./scripts/queryDuanjiFrom.cdc "0x1a478a7149935b63" -n testnet


# Multi-Ecosystem signature
flow keys generate --sig-algo "ECDSA_secp256k1"

flow accounts create --key 023281d6b1c8bfafd70b0d9ffe1f55f61c5844602844e68542655329b33a2c6dffaeccaf987ff08a0df8c57ce58ffee15bbb11361be543106e1600f8927cf2c0 --sig-algo "ECDSA_secp256k1" --hash-algo "SHA2_256"

flow signatures generate "Hello Nika" --signer emulator-Alice

flow signatures verify "hello nika" "77ef43fe4d14c88b6a34b4710557356dc3d02c9139ce20319a61c24b80b4bb4d6775fcd044c69a2d9f710553ce6329d290eb30c739c02669be18ad91c86e8856" 0x906520128060e4a2ca4c126bdb059d23857d99fe51614533f13917adcfd8e3a1d3e0ce05b272b13740f337d47a06eed052d0c0f8c4316cd615d8d06e11ff8e06 --sig-algo "ECDSA_secp256k1" --hash-algo "SHA2_256"

# the signature is created by `routerExample.testSignatureToNormalString`. 
# 'hello nika' is transformed from utf-8 into bytes(u8) first. 
# And the result is as the input to `routerExample.sha3_256FromString`
flow signatures verify "hello nika" "e53176d258d1dce1c7695e842b1a140dab81c019491d355cac160f81e26d548407c695ca518ca89976ca7a0ba0eb5ee1c5e8c6310cddf5d873ff4591928fe33a" 0xbb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025


flow signatures verify "f8d6e0586b0a20c700" "4a5eec8dff59fe5814523ce7b6f1bdb69fd59de4544d02648c4fa3e17d4e471e87695d3d6f5b37eb3e4b2a471a1e02b85ea0f35a970b2b4749e4869480aac278" 0xbb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025

flow signatures verify 0xf8d6e0586b0a20c701119a39f124a1ab62b8438da37605c4b6fa95d5ed2262c624203716f89a83bafc "bb9a06f43535f7690a2227be478723f58acc90eaf64e60a5f38be192e611858ec78f8d1cb12495cf76c384096998ead2828c717c6ff978bac9365d81abbbca10" 0xbb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025

flow transactions send ./transactions/registerRouter.cdc "87c457bf6311cd01a9087489ed386e2eefed70b8d141954754195eac25f95e8ec3d49aacbe73741d42cc66fcca6b7dc4bfe841ac5436120a8878896d82e47449"


# The flow CIL does not support hash algorithm `keccak_256``
# flow signatures verify "hello nika" "e32dd98ca47835a6a3de02f980c54131c62bacc22cf0648056bcf62dc7b3b9ce6f7ca405f64fa52e81ecf1109160fcbb4d6e0e78b722f5be8db9ab0d5f8ad146" 0x906520128060e4a2ca4c126bdb059d23857d99fe51614533f13917adcfd8e3a1d3e0ce05b272b13740f337d47a06eed052d0c0f8c4316cd615d8d06e11ff8e06 --sig-algo "ECDSA_secp256k1" --hash-algo "keccak_256"

flow scripts execute ./scripts/crypto-dev/signatureVerify.cdc 

# Routers
flow scripts execute ./scripts/getRouters.cdc 

# Recver
flow transactions send ./transactions/initRecver.cdc 

flow transactions send ./transactions/destroyRecver.cdc 

# Selector
flow scripts execute ./scripts/test/randTest.cdc

flow scripts execute ./scripts/test/testSelectStatistic.cdc 

flow transactions send ./transactions/test/testRegisterRouter.cdc 101 --gas-limit 10000

# omniverseNFT
flow scripts execute ./omniverseNFT/scripts/SendNFToutTest.cdc 0xf8d6e0586b0a20c7

# message verification
flow scripts execute ./scripts/test/MessageVerificationTest.cdc

# router evaluation
flow scripts execute ./scripts/test/crdTest.cdc

# refresh random seed
flow transactions send ./test/transactions/empty.cdc

# query messages to be sent
flow scripts execute ./scripts/send-recv-message/querySendMessages.cdc 

# query sent message by id
flow scripts execute ./scripts/send-recv-message/querySendMessageByID.cdc "<chain>" <id> -n testnet 

# query message id to be submit
flow scripts execute ./scripts/send-recv-message/queryNextSubmitMessage.cdc 0xc133efc4b43676a0

flow scripts execute ./scripts/send-recv-message/queryNextSubmitMessage.cdc 0x86fc6f40cd9f9c66 -n testnet

flow transactions send ./transactions/send-recv-message/clearSentData.cdc 23 -n testnet --signer testnet-Eason

flow transactions send ./transactions/send-recv-message/setMsgID.cdc 0 -n testnet --signer testnet-Eason

# query locked NFT
flow scripts execute ./omniverseNFT/scripts/getLocked.cdc -n testnet

# query NFTs to be claimed
flow scripts execute ./omniverseNFT/scripts/getClaimMsg.cdc -n testnet

# Send message data management
flow scripts execute ./scripts/test/messageRecorderTest.cdc -n testnet

flow scripts execute ./scripts/send-recv-message/currentSentMessageID.cdc "RINKEBY" -n testnet

flow transactions send ./transactions/send-recv-message/setSentIDForcely.cdc 'RINKEBY' 28 -n testnet --signer testnet-account

# Execution
flow scripts execute ./scripts/send-recv-message/queryExecutions.cdc

flow transactions send ./transactions/send-recv-message/trigger.cdc 

flow scripts execute ./scripts/send-recv-message/queryHistory.cdc