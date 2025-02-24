#include "Worker.h"
#include "Service.h"

//1）它先从sunnet全局队列中获取一个服务，调用服务的ProcessMsgs方法处理eachNum条消息。
//2）处理完成后，调用CheckAndPutGlobal方法（稍后实现），它会判断服务是否还有未处理的消息，如果有，把它重新放回全局队列中，等待下一次处理。
//3）如果全局队列为空，线程将会等待100微秒，然后进入下一次循环。

//线程函数
void Worker::operator()() {
    cout << "worker id: " << id << endl;
    while(true) {
        shared_ptr<Service> srv = Sunnet::inst->PopGlobalQueue();
        if (!srv) {
            //usleep(100);
            Sunnet::inst->WorkerWait();
        } else {
            srv->ProcessMsgs(each_num);
            CheckAndPutGlobal(srv);
        }
    }
}

void Worker::CheckAndPutGlobal(shared_ptr<Service> srv) {
    if (srv->is_exit) {
        return;
    }
    srv->msg_queue_lock.lock();
    if (!srv->msg_queue.empty()) {
        //如果消息队列里还有数据，重新放回全局队列中
        Sunnet::inst->PushGlobalQueue(srv);
    } else {
        srv->SetInGlobal(false);
    }
    srv->msg_queue_lock.unlock();
}