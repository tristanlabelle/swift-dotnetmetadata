file(GLOB_RECURSE SOURCES "*.swift")
add_library(WindowsMetadata STATIC ${SOURCES})
target_link_libraries(WindowsMetadata PUBLIC DotNetMetadata)