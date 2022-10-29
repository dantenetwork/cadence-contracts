import CrossChain from "../../contracts/CrossChain.cdc"

pub fun main() {
    CrossChain.validators.append(0x01);
}
