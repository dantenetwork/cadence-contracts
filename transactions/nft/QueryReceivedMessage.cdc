import ReceivedMessageContract from 0xf8d6e0586b0a20c7;
import CrossChain from 0xf8d6e0586b0a20c7;

pub fun main(
    recvAddress: Address,
    link: String
): {String: UInt128}{
  return ReceivedMessageContract.queryCompletedID(recvAddress: recvAddress, link: link);
}