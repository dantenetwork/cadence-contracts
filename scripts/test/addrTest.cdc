import MessageProtocol from "../../contracts/MessageProtocol.cdc"

pub fun main(): Address {
    let address: Address = 0xf8d6e0586b0a20c7;

    let bytes = address.toBytes();

    let addrStr = String.encodeHex(bytes);

    return MessageProtocol.addressFromHexString(addrHexStr: addrStr)!;
}