import class Foundation.ProcessInfo
import WinSDK

public enum SystemAssemblyPaths {
    public static var framework4: String? {
        #"SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"#.withCString(encodedAs: UTF16.self) { lpSubKey in
            "InstallPath".withCString(encodedAs: UTF16.self) { lpValue in
                var cbData: DWORD = 0
                guard RegGetValueW(HKEY_LOCAL_MACHINE, lpSubKey, lpValue, UInt32(RRF_RT_REG_SZ), nil, nil, &cbData) == ERROR_SUCCESS
                else { return nil }

                var vData: [WCHAR] = [WCHAR](repeating: 0, count: Int(cbData) / MemoryLayout<WCHAR>.size)
                guard RegGetValueW(HKEY_LOCAL_MACHINE, lpSubKey, lpValue, UInt32(RRF_RT_REG_SZ), nil, &vData, &cbData) == ERROR_SUCCESS
                else { return nil }

                return String(decoding: vData, as: Unicode.UTF16.self)
            }
        }
    }

    public static var winMetadata: String? {
        let windowsPath = ProcessInfo.processInfo.environment["windir"]
            ?? ProcessInfo.processInfo.environment["SystemRoot"]
            ?? #"C:\Windows"#
        return "\(windowsPath)\\System32\\WinMetadata"
    }
}