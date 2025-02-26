#include "SocketWorker.h"

//初始化
void SocketWorker::Init() {
    cout << "SocketWorker Init" << endl;
    epfd = epoll_create(1024);
    if (epfd <= 0) {
        printf("epoll_create error\n");
        return;
    }
}

void SocketWorker::AddEvent(int fd) {
    epoll_event ev;
    ev.events = EPOLLIN | EPOLLET;
    ev.data.fd = fd;
    epoll_ctl(epfd, EPOLL_CTL_ADD, fd, &ev);
}

void SocketWorker::RemoveEvent(int fd) {
    epoll_ctl(epfd, EPOLL_CTL_DEL, fd, NULL);
}

void SocketWorker::ModifyEvent(int fd, bool epoll_out) {
    epoll_event ev;
    ev.events = EPOLLIN | EPOLLET;
    ev.data.fd = fd;
    if (epoll_out) {
        ev.events |= EPOLLOUT; //可写（EPOLLOUT）事件
    }
    epoll_ctl(epfd, EPOLL_CTL_MOD, fd, &ev);
}

//线程函数
void SocketWorker::operator()() {
    const int EVENT_SIZE = 1024;
    while (true) {
        struct epoll_event evs[EVENT_SIZE];
        //阻塞等待
        int cnt = epoll_wait(epfd, evs, EVENT_SIZE, -1);

        for (int i = 0; i < cnt; i++) {
            epoll_event ev = evs[i];
            OnEvent(ev);
        }
    }
}

//接收新客户端
void SocketWorker::OnEvent(epoll_event ev) {
    int fd = ev.data.fd;
    auto conn = Sunnet::inst->GetConn(fd);
    if (!conn) {
        printf("OnEvent conn is null\n");
        return;
    }
    bool is_read = ev.events & EPOLLIN;
    bool is_write = ev.events & EPOLLOUT;
    bool is_err = ev.events & EPOLLERR;
    if (conn->type == Conn::TYPE::LISTEN) {
        //监听socket
        if (is_read) {
            OnAccept(conn);
        }
    } else {
        //普通socket
        if (is_read || is_write) {
            OnRW(conn, is_read, is_write);
        }
        if (is_err) {
            printf("OnError fd: %d\n", fd);
        }
    }
}

//传递可读写事件
void SocketWorker::OnAccept(shared_ptr<Conn> conn) {
    int cfd = accept(conn->fd, NULL, NULL);
    if (cfd < 0) {
        printf("accept error\n");
        return;
    }
    //设置非阻塞
    Sunnet::inst->Setnonblocking(cfd);

    //写缓冲区满
    //解决方法1：设置SNDBUFFORCE
    unsigned long buf_size = 4294967295;
    setsockopt(cfd, SOL_SOCKET, SO_SNDBUFFORCE, &buf_size, sizeof(buf_size));

    //添加连接对象
    Sunnet::inst->AddConn(cfd, conn->service_id, Conn::TYPE::CLIENT);
    //添加到epoll监听列表
    AddEvent(cfd);
    //通知服务
    auto msg = make_shared<SocketAcceptMsg>();
    msg->type = BaseMsg::TYPE::SOCKET_ACCEPT;
    msg->listen_fd = conn->fd;
    msg->client_fd = cfd;
    Sunnet::inst->Send(conn->service_id, msg);
}

void SocketWorker::OnRW(shared_ptr<Conn> conn, bool r, bool w) {
    auto msg = make_shared<SocketRWMsg>();
    msg->type = BaseMsg::TYPE::SOCKET_RW;
    msg->fd = conn->fd;
    msg->is_read = r;
    msg->is_write = w;
    Sunnet::inst->Send(conn->service_id, msg);
}