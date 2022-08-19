import MessageProtocol from 0xProfile;

pub fun main(sqosItem: MessageProtocol.InputSQoSArray): MessageProtocol.SQoS {
    
    let sqos = MessageProtocol.SQoS();

    for ele in sqosItem.v {
        sqos.addItem(item: ele.to_SQoSItem());
    }

    return sqos;
}