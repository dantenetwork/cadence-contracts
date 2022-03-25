import CrossChainMessage from 0xf8d6e0586b0a20c7
import CrossChain from 0xf8d6e0586b0a20c7

pub contract Greeting {

    pub let contractName: String; // contract name of destination chain
    pub let actionName: String; // action name of contract

    init(){
      self.contractName="EthereumContractName";
      self.actionName = "EthereumActionName";
    }

    pub fun sendMessage(messageInfo: String): Bool{
      // create cross chain message resource
      let res <-CrossChainMessage.createMessage();
      res.set(message: messageInfo);

      // save message as resource
      self.account.save(<-res, to: /storage/crossChainMessage);
      self.account.link<&{CrossChainMessage.MessageInterface}>(/public/crossChainMessage, target: /storage/crossChainMessage);

      // send message to CrossChain contract
      let ret = CrossChain.sendMessage(address: self.account.address, toChain: "Ethereum", contractName:self.contractName, actionName: self.actionName);

      // destroy cross chain message resource
      let resource <- self.account.load<@CrossChainMessage.Message>(from: /storage/crossChainMessage);
      destroy resource;

      return ret;
    }
}
