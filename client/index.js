const fcl = require("@onflow/fcl");

fcl.config().put("accessNode.api", "http://127.0.0.1:8080");


(async function () {

  const crossChainMessages = await fcl.query({
    cadence: `
        import CrossChainMessage from 0xf8d6e0586b0a20c7
        import CrossChain from 0xf8d6e0586b0a20c7
        import Greeting from 0xf8d6e0586b0a20c7

        pub fun main(): [CrossChainMessage.MessageCore]{
          return Greeting.queryCrossChainMessage();
        }
      `,
  });

  console.log(crossChainMessages);

  const registers = await fcl.query({
    cadence: `
        import CrossChain from 0xf8d6e0586b0a20c7
        import Greeting from 0xf8d6e0586b0a20c7

        pub fun main(): [Address]{
          return CrossChain.queryRegisters();
        }
      `,
  });

  console.log(registers);
}());