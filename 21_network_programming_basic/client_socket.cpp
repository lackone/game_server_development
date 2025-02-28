#include "client_socket.h"

client_socket::client_socket(int index, int port) :_index(index), _port(port) {
    _thread = thread([index, this]() {
        _is_run = true;
        this->msg_run();
        _is_run = false;
    });
}

void client_socket::msg_run() {
    _sock_init();
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        cout << "socket error:" << _sock_err() << endl;
        return;
    }

    sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(_port);

    if (connect(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        cout << "connect error:" << _sock_err() << endl;
        return;
    }

    char buf[1024] = {0};

    string str = "ping_" + to_string(_index);
    cout << "send buf:" << str << endl;
    send(sock, str.c_str(), strlen(str.c_str()), 0);

    recv(sock, buf, sizeof(buf), 0);
    cout << "recv buf:" << buf << endl;

    _sock_close(sock);
    _sock_exit();
}

bool client_socket::is_run() const {
    return _is_run;
}

void client_socket::stop() {
    if (_thread.joinable()) {
        _thread.join();
    }
}