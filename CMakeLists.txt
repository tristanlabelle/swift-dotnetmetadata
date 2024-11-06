cmake_minimum_required(VERSION 3.21.0)

project(SwiftWinRT LANGUAGES C Swift)

if("${CMAKE_EXPORT_COMPILE_COMMANDS}" STREQUAL "")
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

add_subdirectory(Sources)
add_subdirectory(WindowsMetadataCoreLibrary)