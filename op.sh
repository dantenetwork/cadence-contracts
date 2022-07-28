pm2 status

pm2 start client/crosschain/crossChainSync.js —name FlowCrossChain

flow signatures generate "f8d6e0586b0a20c70094641361b92573f46947c203d47820679efed581e155af07528e78fca08374b5" --signer emulator-account

flow transactions send ./examples/verifyByIdentity.cdc "94641361b92573f46947c203d47820679efed581e155af07528e78fca08374b5" "b48d443790ac7d9f2f3a95fecbfb04a24e2b4df1d39017ebf54842e7775547b0507f85e70a6183032de95197f65ef47080a32f6a7b7c99c4de2a05c806c69b5c"

flow scripts execute ./examples/recvCoreDataCreate.cdc 

flow transactions send ./examples/signatureVerify.cdc

flow scripts execute ./examples/getNonce.cdc

flow signatures verify "f8d6e0586b0a20c70094641361b92573f46947c203d47820679efed581e155af07528e78fca08374b5" "5face6343cd4ec1f04d73754960695f5d592f39c690c31107ba4183658fac3e79a86eb9922a4c5434757934176e7c71710b6eae0a28da38e3b08e7c922646ad8" 0xbb499b3527649d37f86d4a16e83aae2f9bd64de510077cf8c5fcb12eafc96c93a0425ac965ce4eb2cc2dd5a350569f10035b4308aadfc544415ddc812f919025

flow transactions send ./transactions/verifyRecvMsgTest.cdc "5face6343cd4ec1f04d73754960695f5d592f39c690c31107ba4183658fac3e79a86eb9922a4c5434757934176e7c71710b6eae0a28da38e3b08e7c922646ad8"


flow transactions send ./transactions/createNFT/registerPunster.cdc "I'm punster Alice!" "Punster Alice's ipfs url"

flow transactions send ./transactions/createNFT/publishDuanji.cdc "I found the dog is so funny!" "ipfs uri 2 is defined"

flow transactions send ./transactions/CrossChainNFT/sendPunster2Opensea.cdc "044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217"

flow transactions send ./transactions/CrossChainNFT/sendDuanji2Opensea.cdc "044cecaa8c944515dfc8bbab90c34a5973e75f60015bfa2af985176c33a91217" 1

flow transactions send ./transactions/CrossChainNFT/claimDuanji.cdc 1 "randomNumber"

flow transactions send ./transactions/CrossChainNFT/claimPunster.cdc 1 "randomNumber"
