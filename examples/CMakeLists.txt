cmake_minimum_required(VERSION 3.16)
project(spf_examples LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

get_filename_component(SPF_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/.." ABSOLUTE)
set(SPF_INCLUDE_DIR "${SPF_ROOT}/include")

if(WIN32)
    set(SPF_LIB_NAME "spf.dll")
elseif(APPLE)
    set(SPF_LIB_NAME "libspf.dylib")
else()
    set(SPF_LIB_NAME "libspf.so")
endif()

set(SPF_LIB_PATH "${SPF_ROOT}/target/release/${SPF_LIB_NAME}")
if(NOT EXISTS "${SPF_LIB_PATH}")
    message(FATAL_ERROR "Rust dynamic library not found: ${SPF_LIB_PATH}. Run 'cargo build --release --package spf' first.")
endif()

add_library(spf SHARED IMPORTED GLOBAL)
set_target_properties(spf PROPERTIES
    IMPORTED_LOCATION "${SPF_LIB_PATH}"
)

add_executable(c_demo c/main.c)
target_include_directories(c_demo PRIVATE "${SPF_INCLUDE_DIR}")
target_link_libraries(c_demo PRIVATE spf)

add_executable(cpp_demo cpp/main.cpp)
target_include_directories(cpp_demo PRIVATE "${SPF_INCLUDE_DIR}")
target_link_libraries(cpp_demo PRIVATE spf)

if(UNIX AND NOT APPLE)
    set_target_properties(c_demo cpp_demo PROPERTIES
        BUILD_RPATH "${SPF_ROOT}/target/release"
    )
endif()
