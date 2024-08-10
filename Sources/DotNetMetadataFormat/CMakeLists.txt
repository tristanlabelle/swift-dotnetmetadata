file(GLOB_RECURSE SOURCES "*.swift")
add_library(DotNetMetadataFormat STATIC ${SOURCES})
target_link_libraries(DotNetMetadataFormat PUBLIC DotNetMetadataCInterop)