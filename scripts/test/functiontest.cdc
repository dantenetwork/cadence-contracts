pub resource A {}

pub fun main(): {String: {UInt128: String}} {
    let map: {String: {UInt128: String}} = {};
    map["nika"] = {};
    // map["nika"]![1] = "hello";
    map["nika"]!.insert(key: 1, "hello");

    let ARes: @A? <- nil;

    destroy ARes;

    return map;
}