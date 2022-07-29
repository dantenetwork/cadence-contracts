pm2 status

pm2 start client/crosschain/crossChainSync.js —name FlowCrossChain

flow signatures generate "f8d6e0586b0a20c700633506677220b0e1c71447ebf1c4b050d44552383501ffdfcb1b46c7a71484f1" --signer emulator-account

flow transactions send ./transactions/verifyByIdentity.cdc "633506677220b0e1c71447ebf1c4b050d44552383501ffdfcb1b46c7a71484f1" "5b150258301bd5847e753c37b76bc97178a106ed15edd51683001abb90c0f43a2ca5d6108fc235cb6485f115c2a2e0fee800be6900f35df7cea6733ef9feec87"

flow scripts execute ./examples/recvCoreDataCreate.cdc 

flow transactions send ./examples/signatureVerify.cdc

flow scripts execute ./examples/getNonce.cdc

flow signatures verify "f8d6e0586b0a20c700633506677220b0e1c71447ebf1c4b050d44552383501ffdfcb1b46c7a71484f1" "5b150258301bd5847e753c37b76bc97178a106ed15edd51683001abb90c0f43a2ca5d6108fc235cb6485f115c2a2e0fee800be6900f35df7cea6733ef9feec87" 0xbb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025

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
