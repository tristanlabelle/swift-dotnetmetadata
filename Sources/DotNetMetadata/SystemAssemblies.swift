import class Foundation.ProcessInfo
import WinSDK

public enum SystemAssemblies {
    public enum DotNetFramework4 {
        public private(set) static var directoryPath: String? = {
            #"SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"#.withCString(encodedAs: UTF16.self) { lpSubKey in
                "InstallPath".withCString(encodedAs: UTF16.self) { lpValue in
                    var cbData: DWORD = 0
                    guard RegGetValueW(HKEY_LOCAL_MACHINE, lpSubKey, lpValue, UInt32(RRF_RT_REG_SZ), nil, nil, &cbData) == ERROR_SUCCESS
                    else { return nil }

                    var vData: [WCHAR] = [WCHAR](repeating: 0, count: Int(cbData) / MemoryLayout<WCHAR>.size)
                    guard RegGetValueW(HKEY_LOCAL_MACHINE, lpSubKey, lpValue, UInt32(RRF_RT_REG_SZ), nil, &vData, &cbData) == ERROR_SUCCESS
                    else { return nil }

                    // https://learn.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-reggetvaluew
                    // > If the data has the REG_SZ, REG_MULTI_SZ or REG_EXPAND_SZ type,
                    // > this size includes any terminating null character or characters.
                    while vData.last == 0 || vData.last == "\\".utf16.first { vData.removeLast() }

                    return String(decoding: vData, as: Unicode.UTF16.self)
                }
            }
        }()

        public static var mscorlibPath: String? { directoryPath.flatMap { "\($0)\\mscorlib.dll" } }
    }

    public enum WinMetadata {
        public private(set) static var directoryPath: String? = {
            var path = [WCHAR](repeating: 0, count: Int(MAX_PATH + 1))
            guard WinSDK.SHGetFolderPathW(nil, CSIDL_SYSTEM, nil, DWORD(SHGFP_TYPE_CURRENT.rawValue), &path) >= 0 else { return nil }
            return String(decodingCString: path, as: UTF16.self) + "\\WinMetadata"
        }()

        public static var windowsFoundationPath: String? { directoryPath.flatMap { "\($0)\\Windows.Foundation.winmd" } }
    }
}