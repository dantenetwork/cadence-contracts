import CrossChainMessage from 0xf8d6e0586b0a20c7;
import CrossChain from 0xf8d6e0586b0a20c7;

pub contract Greeting {

    pub let contractName: String; // contract name of destination chain
    pub let actionName: String; // action name of contract

    init(){
      self.contractName="EthereumContractName";
      self.actionName = "EthereumActionName";

      // create cross chain message resource
      let res <-CrossChainMessage.createMessage();

      // save message as resource
      self.account.save(<-res, to: /storage/crossChainMessage);
      self.account.link<&{CrossChainMessage.BaseMsg}>(/public/crossChainMessage, target: /storage/crossChainMessage);
    }

    pub event showMessage(toChain: String, sender: String, contractName: String, actionName: String, data: String);

    pub fun addCrossChainMessage(toChain: String,data: String): Bool{
      // load resource from storage
      //let resource <- self.account.borrow<@CrossChainMessage.Message>(from: /storage/crossChainMessage);
      let msgRef = self.account.borrow<&CrossChainMessage.Message>(from: /storage/crossChainMessage);
      msgRef!.addMsg(toChain: toChain, sender:self.account.address.toString(), contractName:self.contractName, actionName:self.actionName, data:data);

      // send message to CrossChain contract
      // let ret = CrossChain.sendMessage(address: self.account.address);

      // destroy cross chain message resource
      // destroy resource;
      emit showMessage(toChain: toChain, sender: self.account.address.toString(), contractName: self.contractName, actionName: self.actionName, data:data);
      return true;
    }

    pub fun queryCrossChainMessage(): [CrossChainMessage.MessageCore]{
      let msgRef = self.account.borrow<&CrossChainMessage.Message>(from: /storage/crossChainMessage);
      return msgRef!.getMsg();
    }

    pub fun register():Bool{
      return CrossChain.register(address: self.account.address);
    }
}
