# Error Rollback

This is a very important SQoS item that helps users know whether their remote operations are processed as wished. But an absolute “Error Rollback” is very hard to make out. Consider a situation that when an remote invocation is made from a source chain to a target chain, error happens on the target chain and a rollback reminder is sent from the target chain to the source chain, but unfortunately, the reminder is still error on the source chain, and what shall we do for the next? It is really uncomfortable to engage in an “Error Loop”.  
It seems very hard to solve this problem, but Dante did it. We borrowed the mechanism of [TCP/IP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) three handshakes. An error won’t loop forever and the performance consumption is acceptable.  

`error rollback` is so necessary that we make it as fixed SQoS item. 

## Test workflow



