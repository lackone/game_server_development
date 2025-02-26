#ifndef SUNNET_H
#define SUNNET_H

#include <signal.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <shared_mutex>
#include <unordered_map>
#include <vector>
#include <condition_variable>
#include <iostream>
#include <thread>
#include "Worker.h"
#include "Service.h"
#include "ServiceMsg.h"
#include "SocketWorker.h"
#include "Conn.h"
using namespace std;

class Worker;
class SocketWorker;

class Sunnet {
public:
    //单例
    static Sunnet* inst;
    //服务列表
    unordered_map<uint32_t, shared_ptr<Service>> services;
    uint32_t max_id = 0; //最大ID
    shared_mutex service_lock; //读写锁
public:
    //构造函数
    Sunnet();
    //开始
    void Start();
    //等待运行
    void Wait();
    //增加服务
    uint32_t NewService(shared_ptr<string> type);
    //删除服务
    void KillService(uint32_t id);
    //发送消息
    void Send(uint32_t to_id, shared_ptr<BaseMsg> msg);
    //全局队列操作
    shared_ptr<Service> PopGlobalQueue();
    //加入队列
    void PushGlobalQueue(shared_ptr<Service> srv);
    //创建消息
    shared_ptr<BaseMsg> MakeMsg(uint32_t source, char* buf, int len);
    //唤醒工作线程
    void CheckAndWeakUp();
    //让工作线程等待（仅工作线程调用）
    void WorkerWait();
    //添加conn
    int AddConn(int fd, uint32_t srv_id, Conn::TYPE type);
    //获取conn
    shared_ptr<Conn> GetConn(int fd);
    //删除conn
    bool RemoveConn(int fd);
    //网络连接操作接口
    int Listen(uint32_t port, uint32_t srv_id);
    //关闭连接
    void CloseConn(uint32_t fd);
    //对外Event接口
    void ModifyEvent(int fd, bool epoll_out);
    //设置非阻塞
    int Setnonblocking(int fd);
private:
    //工作线程
    int WORKER_NUM = 3; //工作线程数量
    vector<Worker*> workers; //worker对象
    vector<thread*> workerThreads; //线程
    //socket线程
    SocketWorker* socket_worker;
    thread* socket_worker_thread;
    //全局队列
    queue<shared_ptr<Service>> global_queue;
    int global_queue_len = 0; //队列长度
    mutex global_queue_lock; //锁
    //休眠和唤醒
    condition_variable worker_sleep_cond;
    mutex worker_sleep_lock;
    int worker_sleep_count = 0; //休眠工作线程数
    //conn列表
    unordered_map<uint32_t, shared_ptr<Conn>> conns;
    shared_mutex conns_lock; //读写锁
private:
    //开启工作线程
    void StartWorker();
    //开启socket线程
    void StartSocketWorker();
    //获取服务
    shared_ptr<Service> GetService(uint32_t id);
};



#endif //SUNNET_H
