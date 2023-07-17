import Foundation
import XCTest
import WinSDK
@testable import DotNetMD

final class NetFX45MscorlibTests: XCTestCase {
    internal static var context: MetadataContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        guard let assemblyPath = try? getInstallPath() + "\\mscorlib.dll" else { return }
        context = MetadataContext()
        assembly = try? context.loadAssembly(path: assemblyPath)
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.assembly == nil)
    }

    func testIsMscorlib() throws {
        XCTAssertNotNil(Self.assembly as? Mscorlib)
    }

    func testTypeLookup() throws {
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "System.Object"))
    }

    private static func getInstallPath() throws -> String {
        struct RegistryKeyNotFound: Error {}
        return try #"SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"#.withCString(encodedAs: UTF16.self) { lpSubKey in
            try "InstallPath".withCString(encodedAs: UTF16.self) { lpValue in
                var cbData: DWORD = 0
                guard RegGetValueW(HKEY_LOCAL_MACHINE, lpSubKey, lpValue, UInt32(RRF_RT_REG_SZ), nil, nil, &cbData) == ERROR_SUCCESS
                else { throw RegistryKeyNotFound() }

                var vData: [WCHAR] = [WCHAR](repeating: 0, count: Int(cbData) / MemoryLayout<WCHAR>.size)
                guard RegGetValueW(HKEY_LOCAL_MACHINE, lpSubKey, lpValue, UInt32(RRF_RT_REG_SZ), nil, &vData, &cbData) == ERROR_SUCCESS
                else { throw RegistryKeyNotFound() }

                return String(decoding: vData, as: Unicode.UTF16.self)
            }
        }
    }
}
