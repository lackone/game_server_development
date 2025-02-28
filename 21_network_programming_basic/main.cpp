#include <cstring>
#include <iostream>
#include <list>
#include <memory>

#include "client_socket.h"
#include "network.h"
using namespace std;

//什么是异步呢？异步不会等待，也不会阻塞。
//程序是如何知道回调完成的呢？
//（1）主动询问，每间隔一段时间询问A是否加载完成。
//（2）被动接收，一般在启动事件时会要求注册一个回调函数，事件完成时会主动调用回调函数，以标记事件完成。

//协议是什么呢？
//简单来说就是有格式的数据。A机向B机发送一串字符，这串字符经过层层包装发送到B机，B机根据约定的格式一步步分解成最初的字符串。

//系统差异
//（1）虽然网络API是底层函数，但在Windows系统下创建Socket之前需要调用WSAStartup函数，而退出的时候需要调用WSACleanup函数。
//（2）获取错误的方式也略有不同。在Linux系统下使用errno变量，在Windows下使用WSAGetLastError函数

//网络底层函数说明
//1.函数：：socket   每个网络通信必有一个Socket。
//2.函数：：bind     作用是指定IP和端口开放给客户端连接
//3.函数：：listen   用于对IP地址和端口的监听
//4.函数：：connect  对一个已知地址进行网络连接的函数
//5.函数：：accept   该函数用于监听端口，若：：accept收到数据，则一定有一个新的连接被发起。
//6.函数：：send和：：recv   一对用于发送和接收数据的函数

//recv函数来说，若返回0，则表示在另一端发送了一个FIN结束包，网络已中断。

//所谓阻塞，就是一定要收到数据之后，后面的操作才会继续。


void server_test(int port) {
    _sock_init();

    //2：创建Socket
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        cout << "socket error:" << _sock_err() << endl;
        return;
    }

    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(port);

    //3：绑定IP与端口
    if (bind(sock, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
        cout << "bind error:" << _sock_err() << endl;
        return;
    }

    //4：监听网络
    if (listen(sock, GetListenBacklog()) < 0) {
        cout << "listen error:" << _sock_err() << endl;
        return;
    }

    //5：等待连接
    sockaddr_in client;
    socklen_t len = sizeof(client);
    int cfd = accept(sock, (struct sockaddr *) &client, &len);

    cout << "accept new connection:" << cfd << endl;

    char buf[1024] = {0};

    //6：接收数据
    auto size = recv(cfd, buf, sizeof(buf), 0);
    if (size > 0) {
        cout << "recv buf:" << buf << endl;
        send(cfd, buf, size, 0);
        cout << "send buf:" << buf << endl;
    }

    //7：关闭Socket
    _sock_close(sock);
    _sock_exit();
}

void client_test(int port) {
    _sock_init();

    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        cout << "socket error:" << _sock_err() << endl;
        return;
    }
    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(port);

    if (connect(sock, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
        cout << "connect error:" << _sock_err() << endl;
        return;
    }

    string str = "ping";
    send(sock, str.c_str(), str.size(), 0);

    cout << "send str:" << str << endl;
    char buf[1024] = {0};
    recv(sock, buf, sizeof(buf), 0);
    cout << "recv buf:" << buf << endl;

    _sock_close(sock);
    _sock_exit();
}

//关键点1：Socket值的重用
//关键点2：Socket值是进程级数据    同一时间不同的进程可能存在相同的Socket值的通道。
//关键点3：网络数据的无序与有序     同一个Socket连接，如果先发了Msg0，再发送Msg1，在TCP下，服务端收到的数据一定是有序的，必定是先收到Msg0，再收到Msg1。

void nonblock_server_test(int port) {
    _sock_init();

    //2：创建Socket
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        cout << "socket error:" << _sock_err() << endl;
        return;
    }

    _sock_nonblock(sock); //把阻塞模式变为非阻塞模式

    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(port);

    //3：绑定IP与端口
    if (bind(sock, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
        cout << "bind error:" << _sock_err() << endl;
        return;
    }

    //4：监听网络
    if (listen(sock, GetListenBacklog()) < 0) {
        cout << "listen error:" << _sock_err() << endl;
        return;
    }

    //5：等待连接
    sockaddr_in client;
    socklen_t len = sizeof(client);

    char buf[1024] = {0};
    list<int> socks;

    while (true) {
        int cfd = accept(sock, (struct sockaddr *) &client, &len);
        if (cfd < 0) {
            if (_sock_is_blocked()) {
                continue;
            }
            cout << "accept error:" << _sock_err() << endl;
            continue;
        }

        _sock_nonblock(cfd); //设为非阻塞
        socks.push_back(cfd); //保存客户端fd

        auto iter = socks.begin();

        while (iter != socks.end()) {
            int fd = *iter;
            auto size = recv(fd, buf, sizeof(buf), 0);
            if (size > 0) {
                cout << "recv buf:" << buf << endl;
                send(fd, buf, size, 0);
                cout << "send buf:" << buf << endl;

                _sock_close(fd);
                iter = socks.erase(iter);
            } else {
                iter++;
            }
        }
    }

    //7：关闭Socket
    _sock_close(sock);
    _sock_exit();
}

void nonblock_client_test(int port) {
    list<shared_ptr<client_socket> > clients;
    for (int i = 0; i < 3; i++) {
        clients.push_back(make_shared<client_socket>(i, port));
    }

    // 遍历当前所有ClientSocket类，如果已完成数据收发，就关闭线程，剔除数组
    while (!clients.empty()) {
        auto iter = clients.begin();
        while (iter != clients.end()) {
            auto c = *iter;
            if (c->is_run()) {
                iter++;
                continue;
            }
            c->stop();
            iter = clients.erase(iter);
        }
    }
}

int main(int argc, char *argv[]) {
    if (strcmp(argv[1], "server") == 0) {
        //server_test(atoi(argv[2]));
        nonblock_server_test(atoi(argv[2]));
    } else if (strcmp(argv[1], "client") == 0) {
        //client_test(atoi(argv[2]));
        nonblock_client_test(atoi(argv[2]));
    }
    return 0;
}
