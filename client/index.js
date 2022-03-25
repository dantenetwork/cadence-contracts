import * as fcl from "@onflow/fcl";

fcl.config().put("accessNode.api", "http://127.0.0.1:8080");


var response = await fcl.query({
  cadence: `
        import CrossChain from 0xf8d6e0586b0a20c7
        import Greeting from 0xf8d6e0586b0a20c7

        pub fun main(): Int {
          Greeting.sendMessage(messageInfo:"Hello ");
          return CrossChain.queryMessageCount()
        }
      `,
});

console.log(response);