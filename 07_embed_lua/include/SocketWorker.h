#ifndef SOCKETWORKER_H
#define SOCKETWORKER_H

#include <memory>
#include <sys/epoll.h>
#include <iostream>
#include <unistd.h>
#include "Conn.h"
#include "Sunnet.h"
#include "SocketAcceptMsg.h"
#include "SocketRWMsg.h"
using namespace std;

class Sunnet;

class SocketWorker {
public:
    void Init(); //初始化
    void operator()(); //线程函数
public:
    void AddEvent(int fd);
    void RemoveEvent(int fd);
    void ModifyEvent(int fd, bool epoll_out);
private:
    void OnEvent(epoll_event ev);
    void OnAccept(shared_ptr<Conn> conn);
    void OnRW(shared_ptr<Conn> conn, bool r, bool w);
private:
    int epfd; //epoll描述符
};



#endif //SOCKETWORKER_H
