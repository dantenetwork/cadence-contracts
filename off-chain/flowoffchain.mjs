import fs from 'fs';
import path from 'path';
import fcl from '@onflow/fcl';
import elliptic from 'elliptic';
import {sha256} from 'js-sha256';
import { SHA3 } from 'sha3';


fcl.config().put('accessNode.api', 'http://127.0.0.1:8888');
fcl.config().put('0xProfile', '0xf8d6e0586b0a20c7');

// Get block at height (uses builder function)
// const response = await fcl.send([fcl.getBlock(), fcl.atBlockHeight(1)]).then(fcl.decode);
// console.log(response);

// const account = await fcl.account("0xf8d6e0586b0a20c7");
// console.log(fcl.sansPrefix(account.address));
// console.log(fcl.withPrefix(account.address));

async function exampleHash() {
    const msg2sign = "hello nika";
    console.log(sha256(msg2sign));
    const sha3_256Hash = (msg) => {
        const sha = new SHA3(256);
        sha.update(Buffer.from(msg, 'utf8'));
        return sha.digest().toString('hex');
    };
    console.log(sha3_256Hash(msg2sign))
}

class FlowService {
    constructor(address, privateKey, keyId, hashFun, curveName) {
        this.signerFlowAddress = address;// signer address 
        this.signerPrivateKeyHex = privateKey;// signer private key
        this.signerAccountIndex = keyId;// singer key index
        this.ec = new elliptic.ec(curveName);
        this.hashFunc = hashFun;
    }

    executeScripts = async (script, args) => {
        const response = await fcl.send([fcl.script`${script}`, fcl.args(args)]);
        return await fcl.decode(response);
    }

    sendTx = async ({
        transaction,
        args,
    }) => {
        const response = await fcl.send([
          fcl.transaction`
            ${transaction}
          `,
          fcl.args(args),
          fcl.proposer(this.authzFn),
          fcl.authorizations([this.authzFn]),
          fcl.payer(this.authzFn),
          fcl.limit(9999)
        ]);
    
        return response;
    };

    authzFn = async (txAccount) => {
        const user = await fcl.account(this.signerFlowAddress);
        const key = user.keys[this.signerAccountIndex];

        const pk = this.signerPrivateKeyHex;
        
        return  {
            ...txAccount,
            tempId: `${user.address}-${key.index}`,
            addr: fcl.sansPrefix(user.address),
            keyId: Number(key.index),
            signingFunction: async(signable) => {
                return {
                addr: fcl.withPrefix(user.address),
                keyId: Number(key.index),
                signature: this.sign(signable.message)
                }
            }
        }
    }

    sign = (msg) => {
        const key = this.ec.keyFromPrivate(Buffer.from(this.signerPrivateKeyHex, 'hex'));
        const sig = key.sign(this.hashFunc(msg));
        const n = 32;
        const r = sig.r.toArrayLike(Buffer, 'be', n);
        const s = sig.s.toArrayLike(Buffer, 'be', n);
        return Buffer.concat([r, s]).toString('hex');
    };
}

async function createSubmittion() {
    const fService = new FlowService();

    const script = fs.readFileSync(
        path.join(
            process.cwd(),
            '../scripts/addressTest.cdc'
        ),
        'utf8'
    );
    
    const response = await fService.executeScripts(script, []);
    console.log(response);
}

const ec = new elliptic.ec('p256');

const sha3_256Hash = (msg) => {
    const sha = new SHA3(256);
    sha.update(Buffer.from(msg, 'utf8'));
    return sha.digest();
};

function signWithKey(msg) {

    const key = ec.keyFromPrivate(Buffer.from("69e7e51ead557351ade7a575e947c4d4bd19dd8a6cdf00c51f9c7f6f721b72dc", 'hex'));
    const sig = key.sign(sha3_256Hash(msg));
    const n = 32;
    const r = sig.r.toArrayLike(Buffer, 'be', n);
    const s = sig.s.toArrayLike(Buffer, 'be', n);
    console.log(sig.recoveryParam);
    return Buffer.concat([r, s]).toString('hex');
};

async function testSignature() {
    
    const fService = new FlowService("0xf8d6e0586b0a20c7", "69e7e51ead557351ade7a575e947c4d4bd19dd8a6cdf00c51f9c7f6f721b72dc", 0, sha3_256Hash, "p256");

    const signed = fService.sign('hello nika');
    console.log(signed);
}

// await createSubmittion();
// await exampleHash();
await testSignature();

const signed2 = signWithKey('hello nika');
console.log(signed2);
