cmake_minimum_required(VERSION 3.26.5)

# 头文件目录
include_directories(include)
# 查找./src目录下的所有源文件，保存到DIR_SRCS变量中
aux_source_directory(./src DIR_SRCS)

# 库文件
#find_package (Threads)
#target_link_libraries (06_tcp_network_module ${cmake_THREAD_LIBS_INIT})

# 指定生成目标文件
add_executable(06_tcp_network_module ${DIR_SRCS})