import SentMessageContract from 0xf8d6e0586b0a20c7;
import CrossChain from 0xf8d6e0586b0a20c7;

pub fun main(): [SentMessageContract.SentMessageCore]{
  return SentMessageContract.QueryMessage(msgSender: 0xf8d6e0586b0a20c7, link: "sentMessageVault");
}