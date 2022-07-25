import Locker from 0x01cf0e2f2f715450;

pub fun main():  [MessageProtocol.MessagePayload]{
  return Locker.queryMessage(msgSender: 0x01cf0e2f2f715450, link: "calleeVault");
}