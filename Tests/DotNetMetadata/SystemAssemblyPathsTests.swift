@testable import DotNetMetadata
import Testing
import Foundation

struct SystemAssemblyPathsTests {
    @Test func testFramework4MscorlibExists() throws {
        let path = try #require(SystemAssemblies.DotNetFramework4.mscorlibPath)
        #expect(FileManager.default.fileExists(atPath: path))
    }

    @Test func testWindowsMetadataExists() throws {
        let path = try #require(SystemAssemblies.WinMetadata.windowsFoundationPath)
        #expect(FileManager.default.fileExists(atPath: path))
    }
}