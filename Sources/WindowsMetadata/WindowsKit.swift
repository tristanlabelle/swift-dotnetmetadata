import DotNetMetadata
import class Foundation.FileManager
import WinSDK

/// Represents a Windows (10+) Software Development Kit installation on the current machine.
public final class WindowsKit {
    public let rootDirectory: String
    public let version: FourPartVersion
    public private(set) var cachedExtensions: [Extension]?

    fileprivate init(rootDirectory: String, version: FourPartVersion) {
        self.rootDirectory = rootDirectory
        self.version = version
    }

    public var extensions: [Extension] {
        if let cachedExtensions = cachedExtensions { return cachedExtensions }

        var extensions = [Extension]()
        if let extensionDirs = try? FileManager.default.contentsOfDirectory(atPath: "\(rootDirectory)\\Extension SDKs") {
            for extensionDir in extensionDirs {
                guard FileManager.default.fileExists(atPath: "\(rootDirectory)\\Extension SDKs\\\(extensionDir)\\\(version)\\SDKManifest.xml") else { continue }
                extensions.append(Extension(kit: self, name: extensionDir.lastPathComponent))
            }
        }

        self.cachedExtensions = extensions
        return extensions
    }

    public var applicationPlatformXMLPath: String {
        "\(rootDirectory)\\Platforms\\UAP\\\(version)\\Platform.xml"
    }

    public var unionMetadataPath: String {
        "\(rootDirectory)\\UnionMetadata\\\(version)\\Windows.winmd"
    }

    public func readApplicationPlatform() throws -> ApplicationPlatform {
        try ApplicationPlatform(readingFileAtPath: applicationPlatformXMLPath)
    }

    public func getAPIContractPath(name: String, version: FourPartVersion) -> String {
        "\(rootDirectory)\\References\\\(self.version)\\\(name)\\\(version)\\\(name).winmd"
    }

    /// Gets all installed Windows 10+ kits on the current machine.
    public static func getInstalled() throws -> [WindowsKit] {
        guard let key = try openKey() else { return [] }
        defer { RegCloseKey(key) }
        guard let rootDirectory = try getRoot10(key: key) else { return [] }
        let versions = try getVersions(key: key)
        return versions.map { WindowsKit(rootDirectory: rootDirectory, version: $0) }
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
        "KitsRoot10".withCString(encodedAs: UTF16.self) { valueName -> String? in
            var byteLength: UInt32 = 0
            let result = RegQueryValueExW(key, valueName, nil, nil, nil, &byteLength)
            guard result == ERROR_SUCCESS, byteLength > 0 else { return nil }

            // https://learn.microsoft.com/en-us/windows/win32/api/winreg/nf-winreg-regqueryvalueexw :
            // > A pointer to a variable that specifies the size of the buffer pointed to by the lpData parameter, in bytes.
            // > If the data has the REG_SZ, REG_MULTI_SZ or REG_EXPAND_SZ type,
            // > this size includes any terminating null character or characters unless the data was stored without them.
            var path = [BYTE](repeating: 0, count: Int(byteLength))
            return path.withUnsafeMutableBufferPointer { byteBuffer -> String? in
                guard RegQueryValueExW(key, valueName, nil, nil, byteBuffer.baseAddress, &byteLength) == ERROR_SUCCESS else { return nil }

                let charLength = Int(byteLength) / MemoryLayout<WCHAR>.size
                var charBuffer = UnsafeMutableBufferPointer<WCHAR>(
                    start: UnsafeMutableRawPointer(byteBuffer.baseAddress!).bindMemory(to: WCHAR.self, capacity: charLength),
                    count: charLength)
                while charBuffer.last == 0 {
                    charBuffer = .init(start: charBuffer.baseAddress, count: charBuffer.count - 1)
                }
                return String(utf16CodeUnits: charBuffer.baseAddress!, count: charBuffer.count)
            }
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