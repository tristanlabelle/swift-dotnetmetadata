file(GLOB_RECURSE SOURCES "*.swift")
add_library(DotNetMetadata STATIC ${SOURCES})
target_link_libraries(DotNetMetadata PUBLIC DotNetMetadataFormat)