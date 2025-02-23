cmake_minimum_required(VERSION 3.26.5)
project(game_server_development)

set(CMAKE_CXX_STANDARD 20)

add_executable(game_server_development main.cpp)


add_subdirectory(01_role_start)
add_subdirectory(02_skynet)
add_subdirectory(03_case_ball_battle)
add_subdirectory(04_skynet_advanced)