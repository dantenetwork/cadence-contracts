import StarBazaar from "../contracts/StarBazaar.cdc"

pub fun main(): String {
    log("hello".getType());

    let pool <- StarBazaar.createDEXPool(poolType: "Nika");

    let typeTraits = pool.getType().identifier;
    destroy pool;

    return typeTraits;
}
