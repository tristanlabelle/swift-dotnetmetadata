import DotNetMetadata
import WinSDK
import class Foundation.FileManager

extension WindowsSDK {
    public final class Installation {
        public let rootDirectory: String
        public let version: FourPartVersion

        fileprivate init(rootDirectory: String, version: FourPartVersion) {
            self.rootDirectory = rootDirectory
            self.version = version
        }

        public var applicationPlatformXMLPath: String {
            "\(rootDirectory)\\Platforms\\UAP\\\(version)\\Platform.xml"
        }

        public func readApplicationPlatform() throws -> ApplicationPlatform {
            try ApplicationPlatform(readingFileAtPath: applicationPlatformXMLPath)
        }

        public func getAPIContractPath(name: String, version: FourPartVersion) -> String {
            "\(rootDirectory)\\References\\\(self.version)\\\(name)\\\(version)\\\(name).winmd"
        }
    }

    public static func getInstalled() throws -> [Installation] {
        guard let key = try openKey() else { return [] }
        defer { RegCloseKey(key) }
        guard let rootDirectory = try getRoot10(key: key) else { return [] }
        let versions = try getVersions(key: key)
        return versions.map { Installation(rootDirectory: rootDirectory, version: $0) }
    }

    private static func openKey() throws -> HKEY? {
        "SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots".withCString(encodedAs: UTF16.self) { keyName in
            // From C++/WinRT:
            // > The SDK sometimes stores the 64 bit location into KitsRoot10 which is wrong,
            // > this breaks 64-bit cppwinrt.exe, so work around this by forcing to use the WoW64 hive.
            let KEY_READ: Int32 = 131097
            var key: HKEY? = nil;
            guard RegOpenKeyExW(HKEY_LOCAL_MACHINE, keyName, 0, UInt32(KEY_READ | KEY_WOW64_32KEY), &key) == ERROR_SUCCESS else {
                return nil
            }

            return key
        }
    }

    private static func getRoot10(key: HKEY) throws -> String? {
        "KitsRoot10".withCString(encodedAs: UTF16.self) { valueName in
            var pathByteLength: UInt32 = 0
            guard RegQueryValueExW(key, valueName, nil, nil, nil, &pathByteLength) == ERROR_SUCCESS else { return nil }
            
            // https://learn.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regqueryvalueexw :
            // > A pointer to a variable that specifies the size of the buffer pointed to by the lpData parameter, in bytes.
            // > If the data has the REG_SZ, REG_MULTI_SZ or REG_EXPAND_SZ type,
            // > this size includes any terminating null character or characters unless the data was stored without them.
            var path = [WCHAR](repeating: 0, count: Int(pathByteLength / 2))
            guard RegQueryValueExW(key, valueName, nil, nil, &path, &pathByteLength) == ERROR_SUCCESS else { return nil }

            return String(utf16CodeUnits: path, count: path.count)
        }
    }

    private static func getVersions(key: HKEY) throws -> [FourPartVersion] {
        var subkeyName: [WCHAR] = []
        var versions: [FourPartVersion] = []
        for subkeyIndex in 0... {
            subkeyName.removeAll(keepingCapacity: true)
            var subkeyNameLength: UInt32 = 32
            subkeyName.append(contentsOf: repeatElement(0, count: Int(subkeyNameLength)))
            guard RegEnumKeyExW(key, UInt32(subkeyIndex), &subkeyName, &subkeyNameLength, nil, nil, nil, nil) == ERROR_SUCCESS else { break }
            let version = String(utf16CodeUnits: subkeyName, count: Int(subkeyNameLength))
            versions.append(try FourPartVersion(parsing: version))
        }

        return versions
    }
}