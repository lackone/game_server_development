#include "player.h"

//g++ -shared -o handle.so handle.cpp

extern "C" {
    void work(struct Player *player)
    {
        player->coin = player->coin + 2;
    }
}

