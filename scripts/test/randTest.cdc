pub fun main(): [UInt32] {
    let rands: [UInt32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    
    var loops = 0;
    while loops < 5000 {
        let tmp64 = unsafeRandom();

        var lower32: UInt32 = UInt32(tmp64 & 0x00000000FFFFFFFF);
        var high32: UInt32 = UInt32(tmp64 >> 32);

        //let final64: UInt64 = (UInt64(high32) << 32) + UInt64(lower32);

        //log(tmp64.toString().concat(" : ").concat(lower32.toString()).concat(" : ").concat(high32.toString()).concat(" : ").concat(final64.toString()));

        if high32 < lower32 {
            high32 <-> lower32;
        }

        let pointLower = lower32 % 600;
        let idxLower = pointLower / 50;
        rands[idxLower] = rands[idxLower] + 1;

        let pointHigher = high32 % 600;
        let idxHigher = pointHigher / 50;
        rands[idxHigher] = rands[idxHigher] + 1;

        loops = loops + 1;
    }

    //let ooo: [UInt32] = [1, 2];
    //ooo[0] <-> ooo[1];

    return rands;
}
