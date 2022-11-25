import SentMessageContract from "../../contracts/SentMessageContract.cdc";
import MessageProtocol from "../../contracts/MessageProtocol.cdc";
import OmniverseInformation from "../../contracts/OmniverseInformation.cdc";

pub fun main(): [UInt8] {
    let payload = MessageProtocol.MessagePayload();
    payload.addItem(item: MessageProtocol.createMessageItem(name: "Nika", type: MessageProtocol.MsgType.cdcVecString, value: ["Hello", "Nice Day"])!);
    payload.addItem(item: MessageProtocol.createMessageItem(name: "Luffy", type: MessageProtocol.MsgType.cdcVecU128, value: [UInt128(73), UInt128(37)])!);

    let sqos = MessageProtocol.SQoS();
    sqos.addItem(item: MessageProtocol.SQoSItem(type: MessageProtocol.SQoSType.Challenge, value: [1, 2, 3]));

    let msgToSubmit = SentMessageContract.msgToSubmit(toChain: "Polkadot", 
                                                    sqos: sqos, 
                                                    contractName: OmniverseInformation.getDefaultAddress(chainName: "random"), 
                                                    actionName: OmniverseInformation.getDefaultSelector(chainName: "random"), 
                                                    data: payload,
                                                    callType: 3, 
                                                    callback: nil, 
                                                    commitment: [49, 49], 
                                                    answer: nil);

    let sentMessage = SentMessageContract.SentMessageCore(id: 1, toChain: msgToSubmit.toChain, 
                                                        sender: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,2,3], 
                                                        signer: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,2,3], 
                                                        msgToSubmit: msgToSubmit);
    // log(sentMessage);
    // return "Polkadot".utf8;
    return "SUI_TESTNET".utf8;
    // return String.encodeHex(sentMessage.toBytes());
    // return sentMessage.toBytes();
}