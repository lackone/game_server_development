#ifndef SERVER_H
#define SERVER_H

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <map>
#include <unistd.h>

class Server {
public:
    Server(const char *ip, int port) {
        _addr.sin_family = AF_INET;
        _addr.sin_port = htons(port);
        _addr.sin_addr.s_addr = inet_addr(ip);
        _port = port;
    }

    void start() {
        _listen_fd = socket(AF_INET, SOCK_STREAM, 0);
        bind(_listen_fd, (struct sockaddr *) &_addr, sizeof(_addr));
        listen(_listen_fd, 5);

        _epfd = epoll_create(5);
        add_fd(_listen_fd);

        epoll_event evs[MAX_EVENT_NUM];

        char buf[1024] = {0};
        int num = 0;
        int ret = 0;

        while (1) {
            num = epoll_wait(_epfd, evs, MAX_EVENT_NUM, -1);
            if (num < 0 && errno != EINTR) {
                printf("epoll_wait error\n");
                break;
            }
            for (int i = 0; i < num; i++) {
                int fd = evs[i].data.fd;
                if (fd == _listen_fd && (evs[i].events & EPOLLIN)) {
                    //如果有新的连接过来
                    sockaddr_in client;
                    socklen_t len = sizeof(client);
                    int cfd = accept(_listen_fd, (struct sockaddr *) &client, &len);
                    //添加监听
                    add_fd(cfd);

                    //把连接socket与角色关联起来
                    _roles[cfd] = new Role();
                } else if (evs[i].events & EPOLLIN) {
                    //客户端发送数据过来

                    while (1) {
                        ret = recv(fd, buf, sizeof(buf), 0);
                        if (ret < 0) {
                            if (errno == EAGAIN || errno == EWOULDBLOCK) {
                                break;
                            }
                        } else if (ret == 0) {
                            //客户端关闭连接
                            remove_fd(fd);
                        } else {
                            printf("client data %s\n", buf);
                        }
                    }
                } else if (evs[i].events & EPOLLRDHUP) {
                    //客户端关闭连接
                    remove_fd(fd);
                }
            }
        }
    }

private:
    int setnonblocking(int fd) {
        int old_opt = fcntl(fd, F_GETFL);
        int new_opt = old_opt | O_NONBLOCK;
        fcntl(fd, F_SETFL, new_opt);
        return old_opt;
    }

    void add_fd(int fd) {
        epoll_event ev;
        ev.data.fd = fd;
        ev.events = EPOLLIN | EPOLLET | EPOLLRDHUP;
        epoll_ctl(_epfd, EPOLL_CTL_ADD, fd, &ev);
        setnonblocking(fd);
    }

    void remove_fd(int fd) {
        epoll_ctl(_epfd, EPOLL_CTL_DEL, fd, 0);
        close(fd);
        auto it = _roles.find(fd);
        if (it != _roles.end()) {
            delete _roles[fd];
            _roles.erase(it);
        }
    }

    const static int MAX_EVENT_NUM = 10000;
    sockaddr_in _addr;
    int _port;
    int _listen_fd;
    int _epfd;
    //服务端要把角色坐标转发给所有的客户端，就得有个结构来保存连接信息
    std::map<int, Role *> _roles;
};

#endif //SERVER_H
