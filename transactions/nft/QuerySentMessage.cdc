import SentMessageContract from 0xf8d6e0586b0a20c7;
import CrossChain from 0xf8d6e0586b0a20c7;

pub fun main(): [SentMessageContract.SentMessageCore]{
  return SentMessageContract.QueryMessage(msgSender: 0x01cf0e2f2f715450, link: "sentMessageVault");
}