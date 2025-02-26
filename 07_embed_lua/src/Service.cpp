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
    //Sunnet::inst->Listen(8002, id);

    //创建lua虚拟机
    lua_state = luaL_newstate();
    //开启标准库
    luaL_openlibs(lua_state);

    //注册Sunnet系统API
    LuaAPI::Register(lua_state);

    //执行lua文件
    string file = "../service/" + *type + "/init.lua";
    int is_ok = luaL_dofile(lua_state, file.data());
    if (is_ok) {
        cout << "run lua fail : " << lua_tostring(lua_state, -1) << endl;
    }
    //调用lua函数
    lua_getglobal(lua_state, "OnInit");
    lua_pushinteger(lua_state, id);
    is_ok = lua_pcall(lua_state, 1, 0, 0);
    if (is_ok != 0) {
        cout << "call lua OnInit fail " << lua_tostring(lua_state, -1) << endl;
    }
}

void Service::OnMsg(shared_ptr<BaseMsg> msg) {
    //SERVICE
    if (msg->type == BaseMsg::TYPE::SERVICE) {
        auto m = dynamic_pointer_cast<ServiceMsg>(msg);
        OnServiceMsg(m);
    }
    //SOCKET_ACCEPT
    if (msg->type == BaseMsg::TYPE::SOCKET_ACCEPT) {
        auto m = dynamic_pointer_cast<SocketAcceptMsg>(msg);
        OnAcceptMsg(m);
    }
    //SOCKET_RW
    if (msg->type == BaseMsg::TYPE::SOCKET_RW) {
        auto m = dynamic_pointer_cast<SocketRWMsg>(msg);
        OnRWMsg(m);
    }
}

void Service::OnServiceMsg(shared_ptr<ServiceMsg> msg) {
    //cout << "OnServiceMsg" << endl;

    //调用lua函数
    lua_getglobal(lua_state, "OnServiceMsg");
    lua_pushinteger(lua_state, msg->source);
    lua_pushlstring(lua_state, msg->buf.get(), msg->size);
    int is_ok = lua_pcall(lua_state, 2, 0, 0);
    if (is_ok != 0) {
        cout << "call lua OnServiceMsg fail " << lua_tostring(lua_state, -1) << endl;
    }
}

void Service::OnAcceptMsg(shared_ptr<SocketAcceptMsg> msg) {
    //cout << "OnAcceptMsg" << endl;

    //每一个客户端都关联上ConnWriter
    auto w = make_shared<ConnWriter>();
    w->fd = msg->client_fd;
    writers.emplace(msg->client_fd, w);

    lua_getglobal(lua_state, "OnAcceptMsg");
    lua_pushinteger(lua_state, msg->listen_fd);
    lua_pushinteger(lua_state, msg->client_fd);
    int is_ok = lua_pcall(lua_state, 2, 0, 0);
    if (is_ok != 0) {
        cout << "call lua OnAcceptMsg fail " << lua_tostring(lua_state, -1) << endl;
    }
}

void Service::OnRWMsg(shared_ptr<SocketRWMsg> msg) {
    int fd = msg->fd;
    //可读
    if (msg->is_read) {
        const int BUF_SIZE = 1024;
        char buf[BUF_SIZE];
        int len = 0;

        do {
            len = read(fd, &buf, BUF_SIZE);
            if (len > 0) {
                OnSocketData(fd, buf, len);
            }
        } while (len == BUF_SIZE);

        //一种是套接字的读缓冲区恰好有512字节，一次性全部读出；read会返回-1，并设置errno为EAGAIN（数据读完）
        //只有当read返回0（对端关闭），或者返回非EAGAIN的-1（出错），程序才会进入读取失败的分支。
        if (len <= 0 && errno != EAGAIN) {
            if (Sunnet::inst->GetConn(fd)) {
                //保证OnSocketClose只调用一次
                OnSocketClose(fd);
                Sunnet::inst->CloseConn(fd);
            }
        }
    }
    //可写（注意没有else）
    if (msg->is_write) {
        if (Sunnet::inst->GetConn(fd)) {
            OnSocketWritable(fd);
        }
    }
}

void Service::OnSocketData(int fd, const char *buff, int len) {
    lua_getglobal(lua_state, "OnSocketData");
    lua_pushinteger(lua_state, fd);
    lua_pushlstring(lua_state, buff, len);
    int is_ok = lua_pcall(lua_state, 2, 0, 0);
    if (is_ok != 0) {
        cout << "call lua OnSocketData fail " << lua_tostring(lua_state, -1) << endl;
    }
}

void Service::OnSocketWritable(int fd) {
    auto w = writers[fd];
    w->OnWriteable();
}

void Service::OnSocketClose(int fd) {
    writers.erase(fd);

    lua_getglobal(lua_state, "OnSocketClose");
    lua_pushinteger(lua_state, fd);
    int is_ok = lua_pcall(lua_state, 1, 0, 0);
    if (is_ok != 0) {
        cout << "call lua OnSocketClose fail " << lua_tostring(lua_state, -1) << endl;
    }
}

void Service::OnExit() {
    cout << "[" << *type << " " << id << "] OnExit" << endl;

    //调用lua函数
    lua_getglobal(lua_state, "OnExit");
    int is_ok = lua_pcall(lua_state, 0, 0, 0);
    if (is_ok != 0) {
        cout << "call lua OnExit fail : " << lua_tostring(lua_state, -1) << endl;
    }

    //关闭Lua虚拟机
    lua_close(lua_state);
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
