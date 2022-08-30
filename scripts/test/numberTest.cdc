pub fun main(): UInt32 {

    let sys_validatorNumber: UInt32 = 13;
    let crdRatio: UFix64 = 0.65;

    let crdNumber: UInt32 = UInt32(UFix64(sys_validatorNumber) * crdRatio);

    return crdNumber;
}
