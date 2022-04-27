import fcl from '@onflow/fcl';
import config from 'config';
import elliptic from 'elliptic';
import { SHA3 } from 'sha3';

const ec = new elliptic.ec('p256');

fcl.config()
  .put('accessNode.api', 'http://127.0.0.1:8080');

if (config.get('network') == 'testnet') {
  fcl.config()
    .put('accessNode.api', 'http://access.devnet.nodes.onflow.org:8000');
}

class FlowService {
  constructor() {
    let signer = config.get('emulator');

    if (config.get('network') == 'testnet') {
      signer = config.get('testnet');
    }
    this.signerFlowAddress = signer.address;// signer address 
    this.signerPrivateKeyHex = signer.privateKey;// signer private key
    this.signerAccountIndex = signer.keyId;// singer key index
  }

  // An authorization function must produce the information of the user that is going to sign and a signing function to use the information to produce a signature.
  authorizationFunction = () => {
    console.log('Account:', this.signerFlowAddress)
    return async (account = {}) => {
      // Query signer info
      const user = await this.getAccount(this.signerFlowAddress);
      const key = user.keys[this.signerAccountIndex];

      const sign = this.signWithKey;
      const pk = this.signerPrivateKeyHex;

      return {
        ...account,
        tempId: `${user.address}-${key.index}`,
        addr: fcl.sansPrefix(user.address),
        keyId: Number(key.index),
        signingFunction: (signable) => {
          return {
            addr: fcl.withPrefix(user.address),
            keyId: Number(key.index),
            signature: sign(pk, signable.message),
          };
        }
      };
    };
  };

  getAccount = async (addr) => {
    const { account } = await fcl.send([fcl.getAccount(addr)]);
    return account;
  };

  getSignerAddress = () => {
    return this.signerFlowAddress;
  }

  signWithKey = (privateKey, msg) => {
    const key = ec.keyFromPrivate(Buffer.from(privateKey, 'hex'));
    const sig = key.sign(this.hashMsg(msg));
    const n = 32;
    const r = sig.r.toArrayLike(Buffer, 'be', n);
    const s = sig.s.toArrayLike(Buffer, 'be', n);
    return Buffer.concat([r, s]).toString('hex');
  };

  hashMsg = (msg) => {
    const sha = new SHA3(256);
    sha.update(Buffer.from(msg, 'hex'));
    return sha.digest();
  };

  sendTx = async ({
    transaction,
    args,
    proposer,
    authorizations,
    payer
  }) => {
    if (config.get('network') == 'testnet') {
      transaction = transaction.replaceAll('0xf8d6e0586b0a20c7', '0xad195f2b3524404e');
    }
    const response = await fcl.send([
      fcl.transaction`
        ${transaction}
      `,
      fcl.args(args),
      fcl.proposer(proposer),
      fcl.authorizations(authorizations),
      fcl.payer(payer),
      fcl.limit(9999)
    ]);

    return response;
  };

  executeScript = async ({ script, args }) => {
    if (config.get('network') == 'testnet') {
      script = script.replaceAll('0xf8d6e0586b0a20c7', '0xad195f2b3524404e');
    }
    const response = await fcl.send([fcl.script`${script}`, fcl.args(args)]);
    return await fcl.decode(response);
  };

  getLatestBlockHeight = async () => {
    const block = await fcl.send([fcl.getBlock(true)]);
    const decoded = await fcl.decode(block);
    return decoded.height;
  };
}

export default FlowService
