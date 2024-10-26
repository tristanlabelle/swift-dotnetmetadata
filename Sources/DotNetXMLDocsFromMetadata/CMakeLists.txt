file(GLOB_RECURSE SOURCES "*.swift")
add_library(DotNetXMLDocsFromMetadata STATIC ${SOURCES})
target_link_libraries(DotNetXMLDocsFromMetadata PUBLIC DotNetMetadata DotNetXMLDocs)