#ifndef CLIENT_SOCKET_H
#define CLIENT_SOCKET_H

#include <cstring>
#include <iostream>
#include <thread>
#include "network.h"
using namespace std;

class client_socket {
public:
    client_socket(int index, int port); // 开启了一个线程

    bool is_run() const; // 收发数据是否已完成

    void stop(); // 结束线程

    void msg_run(); // 阻塞式的Socket收发数据流程
private:
    bool _is_run{true};
    int _index;
    thread _thread;
    int _port;
};


#endif //CLIENT_SOCKET_H
