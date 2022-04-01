const fcl = require("@onflow/fcl");

fcl.config().put("accessNode.api", "http://127.0.0.1:8080");


(async function () {

  console.log("//////////////////////////////////////////////////////");
  console.log("///////////// Query Sent Messages ////////////////////");
  console.log("//////////////////////////////////////////////////////");

  const sentMessages = await fcl.query({
    cadence: `
        import SentMessageContract from 0xf8d6e0586b0a20c7
        import CrossChain from 0xf8d6e0586b0a20c7
        import Greeting from 0xf8d6e0586b0a20c7

        pub fun main(): [SentMessageContract.SentMessageCore]{
          return Greeting.queryCrossChainSentMessage();
        }
      `,
  });

  console.log(sentMessages);

  console.log("//////////////////////////////////////////////////////");
  console.log("///////////// Query Received Messages ////////////////");
  console.log("//////////////////////////////////////////////////////");

  const receivedMessages = await fcl.query({
    cadence: `
        import ReceivedMessageContract from 0xf8d6e0586b0a20c7
        import CrossChain from 0xf8d6e0586b0a20c7
        import Greeting from 0xf8d6e0586b0a20c7

        pub fun main(): [ReceivedMessageContract.ReceivedMessageArray]{
          return Greeting.queryCrossChainReceivedMessage();
        }
      `,
  });

  for (let i in receivedMessages) {
    console.log(receivedMessages[i]);
  }


  console.log("//////////////////////////////////////////////////////");
  console.log("///////////////// Query Registers ////////////////////");
  console.log("//////////////////////////////////////////////////////");

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