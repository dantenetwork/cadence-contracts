pub fun main(): String {
    var rawBuffer: [UInt8] = [];

    let int32Vec: [Int32] = [99, 88, 77];
    let str = "Hello Nika";

    for ele in int32Vec {
        rawBuffer = rawBuffer.concat(ele.toBigEndianBytes());
        log(ele.toBigEndianBytes());
    }

    rawBuffer = rawBuffer.concat(str.utf8);

    return String.encodeHex(rawBuffer);
}