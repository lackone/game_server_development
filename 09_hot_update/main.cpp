#include <iostream>
#include <dlfcn.h>
#include <unistd.h>

#include "player.h"
using namespace std;

typedef void (*work)(struct Player *player);

//通过调用SO来实现热更新
void work_wrap(struct Player *player) {
    void *handle = dlopen("./handle.so", RTLD_LAZY);
    printf("%x\n", handle);
    work w = (work) dlsym(handle, "work");
    w(player);
    dlclose(handle);
}

//g++ -o main main.c -ldl
int main() {
    struct Player player = {0, 0, 0};
    while (1) {
        work_wrap(&player);
        printf("player coin: %d\n", player.coin);
        sleep(1);
    }
    return 0;
}
