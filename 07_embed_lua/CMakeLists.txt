cmake_minimum_required(VERSION 3.26.5)

# 头文件目录
include_directories(include)
# 查找./src目录下的所有源文件，保存到DIR_SRCS变量中
aux_source_directory(./src DIR_SRCS)

# 指定生成目标文件
add_executable(07_embed_lua ${DIR_SRCS})

# 添加库文件路径
link_directories(${cmake_CURRENT_SOURCE_DIR}/3rd/lua-5.4.7/src/)

#Lua头文件、库
include_directories(./3rd/lua-5.4.7/src)
target_link_libraries(07_embed_lua liblua.a)
target_link_libraries(07_embed_lua dl)