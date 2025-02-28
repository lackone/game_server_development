#ifndef NETWORK_H
#define NETWORK_H

#ifdef __linux__
// Linux implementation
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <fcntl.h>

#define SOCKET int
#define INVALID_SOCKET -1

#define _sock_init( )
#define _sock_exit( )
#define _sock_err( )	errno
#define _sock_close( fd ) ::close( fd )

#define _sock_nonblock( fd ) { int flags = fcntl(fd, F_GETFL, 0); fcntl(fd, F_SETFL, flags | O_NONBLOCK); }

#define _sock_is_blocked()	(errno == EAGAIN || errno == 0)

#elif defined(_WIN32)
// Windows implementation
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#define _sock_init( )	{ WSADATA wsaData; WSAStartup( MAKEWORD(2, 2), &wsaData ); }
#define _sock_exit( )	{ WSACleanup(); }
#define _sock_err( )	WSAGetLastError()
#define _sock_close( fd ) ::closesocket( fd )

#define _sock_nonblock( fd )	{ unsigned long param = 1; ioctlsocket(fd, FIONBIO, (unsigned long *)&param); }

#define _sock_is_blocked()	(WSAGetLastError() == WSAEWOULDBLOCK)

#else
// Other platforms
#endif

inline int GetListenBacklog() {
    int backlog = 10;
#ifndef WIN32
    char *str = nullptr;
    if ((str = getenv("LISTENQ")) != nullptr) {
        backlog = atoi(str);
    }
#endif
    return backlog;
}

#endif //NETWORK_H
