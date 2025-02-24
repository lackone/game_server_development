#include "Sunnet.h"

//“声明” 用于向编译器表明变量的类型和名字
//“定义”用于为变量分配存储空间

//所有头文件声明静态变量都需在源文件中定义
Sunnet *Sunnet::inst = nullptr;

Sunnet::Sunnet() {
    inst = this;
}

void Sunnet::Start() {
    cout << "Hello Sunnet" << endl;
    //开启worker
    StartWorker();
}

//开启工作线程
void Sunnet::StartWorker() {
    for (int i = 0; i < WORKER_NUM; i++) {
        cout << "start worker thread: " << i << endl;
        //创建线程对象
        Worker *worker = new Worker();
        worker->id = i;
        worker->each_num = 2 << i; //“2＜＜i”代表2的i次方即可
        //创建线程
        thread *wt = new thread(*worker);
        //添加数组
        workers.push_back(worker);
        workerThreads.push_back(wt);
    }
}

//等待运行
void Sunnet::Wait() {
    if (workerThreads[0]) {
        workerThreads[0]->join();
    }
}

//增加服务
uint32_t Sunnet::NewService(shared_ptr<string> type) {
    auto srv = make_shared<Service>();
    srv->type = type;
    service_lock.lock();
    srv->id = max_id;
    max_id++;
    services.emplace(srv->id, srv);
    service_lock.unlock();
    srv->OnInit(); //初始化
    return srv->id;
}

//删除服务
void Sunnet::KillService(uint32_t id) {
    shared_ptr<Service> srv = GetService(id);
    if (!srv) {
        return;
    }
    //退出前
    srv->OnExit();
    srv->is_exit = true;
    //删除
    service_lock.lock();
    services.erase(id);
    service_lock.unlock();
}

//获取服务
shared_ptr<Service> Sunnet::GetService(uint32_t id) {
    shared_ptr<Service> srv = nullptr;
    service_lock.lock_shared();
    //查找
    auto iter = services.find(id);
    if (iter != services.end()) {
        srv = iter->second;
    }
    service_lock.unlock_shared();
    return srv;
}

//发送消息
void Sunnet::Send(uint32_t to_id, shared_ptr<BaseMsg> msg) {
    //其一，发送方（服务1）将消息插入接收方（服务2）的消息队列中（阶段①）；
    //其二，如果接收方（服务2）不在全局队列中，将它插入全局队列（阶段②），使工作线程能够处理它。
    shared_ptr<Service> to_srv = GetService(to_id);
    if (!to_srv) {
        cout << "send fail, to_srv not exist to_id: " << to_id << endl;
        return;
    }

    //插入目标服务的消息队列
    to_srv->PushMsg(msg);
    //检查并放入全局队列
    bool has_push = false;
    to_srv->in_global_lock.lock();
    if (!to_srv->in_global) {
        //如果不在全局队列里
        PushGlobalQueue(to_srv);
        to_srv->in_global = true;
        has_push = true;
    }
    to_srv->in_global_lock.unlock();

    if (has_push) {
        //唤醒工作线程
        CheckAndWeakUp();
    }
}

//全局队列操作
shared_ptr<Service> Sunnet::PopGlobalQueue() {
    shared_ptr<Service> srv = nullptr;
    global_queue_lock.lock();
    if (!global_queue.empty()) {
        srv = global_queue.front();
        global_queue.pop();
        global_queue_len--;
    }
    global_queue_lock.unlock();
    return srv;
}

//加入队列
void Sunnet::PushGlobalQueue(shared_ptr<Service> srv) {
    global_queue_lock.lock();
    global_queue.push(srv);
    global_queue_len++;
    global_queue_lock.unlock();
}


//创建消息
shared_ptr<BaseMsg> Sunnet::MakeMsg(uint32_t source, char *buf, int len) {
    auto msg = make_shared<ServiceMsg>();
    msg->type = BaseMsg::TYPE::SERVICE;
    msg->source = source;
    //基本类型的对象没有析构函数，
    //所以用delete 或 delete[]都可以销毁基本类型数组；
    //智能指针默认使用delete销毁对象，
    //所以无须重写智能指针的销毁方法
    msg->buf = shared_ptr<char>(buf);
    msg->size = len;
    return msg;
}

//1）是否有陷入休眠的线程。如果所有线程都在工作，无须唤醒。
//2）正在工作的线程是否足够。比如系统中只有2个待处理的服务 （globalLen），而系统开启了5条工作线程（WORKER_NUM），目前只 有1条线程在休眠（sleepCount），那剩下的4条线程正在工作，足以 应对。
//唤醒工作线程
void Sunnet::CheckAndWeakUp() {
    unique_lock<mutex> lock(worker_sleep_lock);

    printf("worker_sleep_count = %d\n", worker_sleep_count);

    if (worker_sleep_count == 0) {
        return;
    }

    if (WORKER_NUM - worker_sleep_count <= global_queue_len) {
        std::cout << "Wake up" << std::endl;
        worker_sleep_cond.notify_one(); // 唤醒一个等待的线程
    }
}

//让工作线程等待（仅工作线程调用）
void Sunnet::WorkerWait() {
    //条件变量陷入休眠的写法就是要按照“加锁-XXX-等待-XXX--解锁” 的结构来写。
    unique_lock<mutex> lock(worker_sleep_lock);

    worker_sleep_count++;

    printf("阻塞\n");

    worker_sleep_cond.wait(lock);

    printf("唤醒\n");

    worker_sleep_count--;
}
