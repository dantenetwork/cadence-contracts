import fcl from "@onflow/fcl";
import FlowService from '../flow.mjs';
import fs from 'fs';
import path from 'path';
import types from "@onflow/types";

const flowService = new FlowService();
const authorization = flowService.authorizationFunction();

(async function(){
    const privateKey = '97ab4c06955fce4489b91be34d8b2ccb0da3114b6eba739715ca014221d3bb4d';
    const publicKey = 'df58ca9f760d5946882da3230455c6815ccda788e5fe244c844feb19d7c2c2d86c2825ce7c922e87efbaf2bb2425efbd7e09e9b3b62b46aa61c045a17dd458f3';

    const message = "FOO";
    const msg = Buffer.from(message).toString("hex");

    try{
        // sign message
        // hash = SHA3_256
        // elliptic = ECDSA_P256
        const signature = await flowService.signWithKey(privateKey, msg);
        console.log(signature);

        // verify message on chain

        // setup account
        const transaction = fs.readFileSync(
            path.join(
            process.cwd(),
            './transactions/nft/SyncReceivedMessage.cdc'
            ),
            'utf8'
        );

        let response = await flowService.sendTx({
            transaction,
            args: [
              fcl.arg(message, types.String),
              fcl.arg(publicKey, types.String),
              fcl.arg(signature, types.String)
            ],
            proposer: authorization,
            authorizations: [authorization],
            payer: authorization
          });

          console.log('Tx Sent:', response);

          console.log('Waiting for the transaction to be sealed.');
          await fcl.tx(response).onceSealed();
          console.log('Transaction sealed.');
        
    }catch(e){
        console.log(e);
    }
})();