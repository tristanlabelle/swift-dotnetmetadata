@testable import DotNetMetadata
import XCTest
import Foundation

final class SystemAssemblyPathsTests: XCTestCase {
    func testFramework4MscorlibExists() throws {
        let path = try XCTUnwrap(SystemAssemblies.DotNetFramework4.mscorlibPath)
        XCTAssert(FileManager.default.fileExists(atPath: path))
    }

    func testWindowsMetadataExists() throws {
        let path = try XCTUnwrap(SystemAssemblies.WinMetadata.windowsFoundationPath)
        XCTAssert(FileManager.default.fileExists(atPath: path))
    }
}