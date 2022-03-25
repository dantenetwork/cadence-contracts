pub contract CrossChainMessage{
    // Interface is used for access control.
    pub resource interface MessageInterface{
        pub var msg: String;

        pub fun set(message: String);

        pub fun get(): String;
    }

    // Define Message for sender contract
    pub resource Message: MessageInterface{
        pub var msg: String;

        init(){
            self.msg = "";
        }

        pub fun set(message: String){
            self.msg = message;
        }

        pub fun get(): String{
            return self.msg;
        }
    }

    pub fun createMessage(): @Message{
        return <- create Message()
    }
}