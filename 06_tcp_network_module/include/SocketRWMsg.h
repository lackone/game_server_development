#ifndef SOCKETRWMSG_H
#define SOCKETRWMSG_H

#include "BaseMsg.h"

class SocketRWMsg : public BaseMsg {
public:
    int fd; //发生事件的套接字描述符
    bool is_read = false; //可读
    bool is_write = false; //可写
};



#endif //SOCKETRWMSG_H
