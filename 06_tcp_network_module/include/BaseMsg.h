#ifndef MSG_H
#define MSG_H

#include <iostream>

//消息基类
class BaseMsg {
public:
    //消息类型
    enum TYPE {
        SERVICE = 1,
        SOCKET_ACCEPT = 2, //有新的客户端连接
        SOCKET_RW = 3, //客户端可读可写
    };
    uint8_t type; //消息类型
    virtual ~BaseMsg() {} //当一个类有子类时，它的析构函数必须是虚函数。
};



#endif //MSG_H
