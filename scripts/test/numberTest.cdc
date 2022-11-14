pub resource RTest {};

pub fun main(): [UInt8] {

/*
    let sys_validatorNumber: UInt32 = 13;
    let crdRatio: UFix64 = 0.65;

    let crdNumber: UInt64 = UInt64(UFix64(sys_validatorNumber) * crdRatio);

    let rt <- create RTest();

    let rstNumber = rt.uuid;

    destroy rt;

    return rstNumber;

    let a: UInt128 = 10;
    return a.toBigEndianBytes();
*/
    let preX: UFix64 = 0.12;
    log(preX.toBigEndianBytes());
    let xu8 = preX.toBigEndianBytes();
    //let afterX = UFix64.fromString(String.encodeHex(xu8));
    let after = UFix64.fromBigEndianBytes(xu8);
    log(afterX);
    return xu8;
}
