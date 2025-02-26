#ifndef CONN_H
#define CONN_H

#include <iostream>
using namespace std;
//自定义连接类。服务端框架通常会进一步封装套接字，以保存一些自定义的套接字状态。

class Conn {
public:
    enum TYPE {
        LISTEN = 1, //监听
        CLIENT = 2, //客户端
    };
    uint8_t type;
    int fd;
    uint32_t service_id;
};



#endif //CONN_H
