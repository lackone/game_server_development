cmake_minimum_required(VERSION 3.26.5)
project(game_server_development)

set(CMAKE_CXX_STANDARD 20)

add_executable(game_server_development main.cpp)


add_subdirectory(01_role_start)
add_subdirectory(02_skynet)
add_subdirectory(03_case_ball_battle)
add_subdirectory(04_skynet_advanced)
add_subdirectory(05_C++_concurrency)
add_subdirectory(06_tcp_network_module)
add_subdirectory(07_embed_lua)
add_subdirectory(08_sync_algorithm)