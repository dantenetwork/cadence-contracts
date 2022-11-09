pub fun main(): {String: {UInt128: String}} {
    let map: {String: {UInt128: String}} = {};
    map["nika"] = {};
    // map["nika"]![1] = "hello";
    map["nika"]!.insert(key: 1, "hello");

    return map;
}