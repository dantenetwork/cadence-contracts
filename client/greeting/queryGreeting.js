import fcl from '@onflow/fcl';

fcl.config().put('accessNode.api', 'http://127.0.0.1:8080');

(async function () {

  console.log('//////////////////////////////////////////////////////');
  console.log('///////////// Query Sent Messages ////////////////////');
  console.log('//////////////////////////////////////////////////////');

  const sentMessages = await fcl.query({
    cadence: `
        import SentMessageContract from 0x166d0e1b0499cde8
        import CrossChain from 0x166d0e1b0499cde8
        import Greeting from 0x166d0e1b0499cde8

        pub fun main(): [SentMessageContract.SentMessageCore]{
          return Greeting.querySentMessageVault();
        }
      `,
  });

  console.log(sentMessages);

  console.log('//////////////////////////////////////////////////////');
  console.log('///////////// Query Received Messages ////////////////');
  console.log('//////////////////////////////////////////////////////');

  const lastReceivedMessages = await fcl.query({
    cadence: `
        import ReceivedMessageContract from 0x166d0e1b0499cde8
        import CrossChain from 0x166d0e1b0499cde8
        import Greeting from 0x166d0e1b0499cde8

        pub fun main(): ReceivedMessageContract.ReceivedMessageArray{
          let length =  Greeting.getReceivedMessageVaultCount();
          return Greeting.queryReceivedMessageVaultById(messageId: length - 1);
        }
      `,
  });

  console.log(lastReceivedMessages);

  console.log('//////////////////////////////////////////////////////');
  console.log('///////////////// Query Registers ////////////////////');
  console.log('//////////////////////////////////////////////////////');

  const registers = await fcl.query({
    cadence: `
        import CrossChain from 0x166d0e1b0499cde8
        import Greeting from 0x166d0e1b0499cde8

        pub fun main(): [Address]{
          return CrossChain.queryRegisteredContracts();
        }
      `,
  });

  console.log(registers);
}());