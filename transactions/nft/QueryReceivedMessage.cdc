import ReceivedMessageContract from 0xf8d6e0586b0a20c7;
import CrossChain from 0xf8d6e0586b0a20c7;

pub fun main():  {String: [ReceivedMessageContract.ReceivedMessageCache]}{
  return ReceivedMessageContract.QueryMessage(msgSender: 0xf8d6e0586b0a20c7, link: "receivedMessageVault");
}