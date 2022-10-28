import SentMessageContract from "./SentMessageContract.cdc"
import ReceivedMessageContract from "./ReceivedMessageContract.cdc"
import CrossChain from "./CrossChain.cdc"

pub contract Regestery {
    /**
      * Register the address of accouts wanna to receive visiting from other chains into cross chain contract
      * @param address - address of account
      */
    pub fun registerRecvAccount(address: Address, link: String): Bool{
        // log("registering receiver...");
        let pubLink = PublicPath(identifier: link);
        let recverRef = getAccount(address).getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(pubLink!).borrow() ?? panic("invalid recver address or `link`!");
        if (!recverRef.isOnline()) {
            panic("The recver is offline!");
        }
        
        // add or update contract's address into RegisteredContracts
        CrossChain.registerRecvAccount(address: address, link: link);
        return true;
    }

    /*Remove registered recver. Needs signature verification */ 
    pub fun removeRecvAccount(address: Address, link: String): Bool {
        // Verify the signature
        let pubLink = PublicPath(identifier: link);
        let recverRef = getAccount(address).getCapability<&{ReceivedMessageContract.ReceivedMessageInterface}>(pubLink!).borrow() ?? panic("invalid recver address or `link`!");
        if (recverRef.isOnline()) {
            panic("The recver is online!");
        }

        CrossChain.removeRecvAccount(address: address, link: link);
        return true;
    }

    /**
      * Register the address of accouts wanna to send messages to other chains' contract
      * @param address - address of account
      */
    pub fun registerSendAccount(address: Address, link: String): Bool{
        // log("registering sender...");
        let pubLink = PublicPath(identifier: link);
        let senderRef = getAccount(address).getCapability<&{SentMessageContract.SentMessageInterface}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
        if (!senderRef.isOnline()) {
            panic("The sender is offline!");
        }
        
        // add or update contract's address into RegisteredContracts
        CrossChain.registerSendAccount(address: address, link: link);

        return true;
    }

    /// Remove registered sender. Needs signature verification
    pub fun removeSendAccount(address: Address, link: String): Bool {
        // Verify the signature
        let pubLink = PublicPath(identifier: link);
        let senderRef = getAccount(address).getCapability<&{SentMessageContract.SentMessageInterface}>(pubLink!).borrow() ?? panic("invalid sender address or `link`!");
        if (senderRef.isOnline()) {
            panic("The sender is online!");
        }

        CrossChain.removeSendAccount(address: address, link: link);
        return true;
    }
}