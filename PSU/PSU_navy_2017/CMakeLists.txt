cmake_minimum_required(VERSION 3.9)
project(PSU_navy_2017)

set(CMAKE_CXX_STANDARD 11)
file(GLOB_RECURSE SRCS *.c)
file(GLOB_RECURSE INCL *.h)
include_directories(include)

add_executable(lemin
        ${SRCS}
        ${INCL})