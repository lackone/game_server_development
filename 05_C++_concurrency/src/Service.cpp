#include "Service.h"

Service::Service() {

}

Service::~Service() {

}

//插入消息
void Service::PushMsg(shared_ptr<BaseMsg> msg) {
    //临界区必须很小，不然会影响程序效率
    msg_queue_lock.lock();
    msg_queue.push(msg);
    msg_queue_lock.unlock();
}

//取出一条消息
shared_ptr<BaseMsg> Service::PopMsg() {
    shared_ptr<BaseMsg> msg = nullptr;
    msg_queue_lock.lock();
    if (!msg_queue.empty()) {
        //取一条消息
        msg = msg_queue.front();
        msg_queue.pop();
    }
    msg_queue_lock.unlock();
    return msg;
}

//回调函数
void Service::OnInit() {
    cout << "[" << *type << " " << id << "] OnInit" << endl;
}

void Service::OnMsg(shared_ptr<BaseMsg> msg) {
  return;
    if (msg->type == BaseMsg::TYPE::SERVICE) {
        auto m = dynamic_pointer_cast<ServiceMsg>(msg);
        cout << "[" << *type << " " << id << "] OnMsg " << m->buf << endl;

        auto ret = Sunnet::inst->MakeMsg(id, new char[20]{'p', 'i', 'n', 'g', '\0'}, 20);

        Sunnet::inst->Send(m->source, ret);
    }
}

void Service::OnExit() {
    cout << "[" << *type << " " << id << "] OnExit" << endl;

}

//执行消息
bool Service::ProcessMsg() {
    shared_ptr<BaseMsg> msg = PopMsg();
    if (msg) {
        OnMsg(msg); //调用回调函数OnMsg。
        return true;
    } else {
        return false;
    }
}

//处理N条消息，返回值代表是否处理
void Service::ProcessMsgs(int max) {
    for (int i = 0; i < max; i++) {
        bool ret = ProcessMsg();
        if (!ret) {
            break;
        }
    }
}

//线程安全地设置inGlobal
void Service::SetInGlobal(bool is_in_global) {
    in_global_lock.lock();
    in_global = is_in_global;
    in_global_lock.unlock();
}