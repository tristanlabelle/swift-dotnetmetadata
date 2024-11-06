add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/mscorlib.winmd"
    COMMAND powershell.exe -File "${CMAKE_CURRENT_SOURCE_DIR}/Assemble.ps1"
        -SourcePath "${CMAKE_CURRENT_SOURCE_DIR}/mscorlib.il"
        -OutputPath "${CMAKE_CURRENT_BINARY_DIR}/mscorlib.winmd"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/mscorlib.il")
add_custom_target(mscorlib_winmd ALL
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/mscorlib.winmd")