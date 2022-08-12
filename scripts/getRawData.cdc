pub fun main(): String {
    var rawBuffer: [UInt8] = [];

    // 0x is not normally processed when making encodeHex opearation
    // rawBuffer.append("0".utf8[0]);
    // rawBuffer.append("x".utf8[0]);

    let int32Vec: [Int32] = [99, 88, 77];
    let str = "Hello Nika";

    for ele in int32Vec {
        rawBuffer = rawBuffer.concat(ele.toBigEndianBytes());
        log(ele.toBigEndianBytes());
    }

    rawBuffer = rawBuffer.concat(str.utf8);

    return "0x".concat(String.encodeHex(rawBuffer));
}
