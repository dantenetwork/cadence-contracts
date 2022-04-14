import SentMessageContract from 0x166d0e1b0499cde8;
import CrossChain from 0x166d0e1b0499cde8;
import NFTCrossChain from 0x166d0e1b0499cde8;

pub fun main(): [SentMessageContract.SentMessageCore]{
  return NFTCrossChain.querySentMessageVault();
}