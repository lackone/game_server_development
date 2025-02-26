#ifndef SOCKETACCEPTMSG_H
#define SOCKETACCEPTMSG_H

#include "BaseMsg.h"

class SocketAcceptMsg : public BaseMsg {
public:
    int listen_fd; //监听套接字的描述符
    int client_fd; //新连入客户端的套接字描述符
};



#endif //SOCKETACCEPTMSG_H
