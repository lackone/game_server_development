#ifndef SERVICE_H
#define SERVICE_H

#include <queue>
#include <memory>
#include <thread>
#include <string>
#include <mutex>
#include "BaseMsg.h"
#include "ServiceMsg.h"
#include "Sunnet.h"

using namespace std;

class Service {
public:
    //唯一id
    uint32_t id;
    //类型
    shared_ptr<string> type;
    //是否退出
    bool is_exit = false;
    //消息列表
    queue<shared_ptr<BaseMsg>> msg_queue;
    //锁
    mutex msg_queue_lock;
    //标记是否在全局队列，true:表示在队列中，或正在处理
    bool in_global = false;
    //锁
    mutex in_global_lock;
public:
    Service();
    ~Service();
    //回调函数
    void OnInit();
    void OnMsg(shared_ptr<BaseMsg> msg);
    void OnExit();
    //插入消息
    void PushMsg(shared_ptr<BaseMsg> msg);
    //执行消息
    bool ProcessMsg();
    void ProcessMsgs(int max);
    //线程安全地设置inGlobal
    void SetInGlobal(bool is_in_global);
private:
    //取出一条消息
    shared_ptr<BaseMsg> PopMsg();
};



#endif //SERVICE_H
