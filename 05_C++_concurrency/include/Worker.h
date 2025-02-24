#ifndef WORKER_H
#define WORKER_H

#include <unistd.h>
#include <iostream>
#include <thread>
#include "Sunnet.h"
#include "Service.h"
using namespace std;

class Sunnet;
class Service;

class Worker {
public:
    int id; //编号
    int each_num; //每次处理多少条消息
    void operator()(); //线程函数
private:
    //辅助函数
    void CheckAndPutGlobal(shared_ptr<Service> srv);
};


#endif //WORKER_H
