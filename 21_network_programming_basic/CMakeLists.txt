include_directories(.)

aux_source_directory(. SRC_LIST)

add_executable(21_network_programming_basic main.cpp ${SRC_LIST})