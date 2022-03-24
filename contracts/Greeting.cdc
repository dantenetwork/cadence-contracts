import CrossChainMessage from 0x01
import CrossChain from 0x02

pub contract Greeting {

    pub fun sendMessage(messageInfo: String): Bool{
      // create cross chain message resource
      let res <-CrossChainMessage.createMessage();
      res.set(message: messageInfo);

      // save message as resource
      self.account.save(<-res, to: /storage/crossChainMessage);
      self.account.link<&{CrossChainMessage.MessageInterface}>(/public/crossChainMessage, target: /storage/crossChainMessage);

      // send message to CrossChain contract
      let ret = CrossChain.sendMessage(address: self.account.address);

      // destroy cross chain message resource
      let resource <- self.account.load<@CrossChainMessage.Message>(from: /storage/crossChainMessage);
      destroy resource;

      return ret;
    }
}
