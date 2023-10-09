@testable import DotNetMetadata
import XCTest
import Foundation

final class SystemAssemblyPathsTests: XCTestCase {
    func testFramework4MscorlibExists() throws {
        let path = try "\(XCTUnwrap(SystemAssemblyPaths.framework4))\\\(Mscorlib.filename)"
        XCTAssert(FileManager.default.fileExists(atPath: path))
    }

    func testWindowsMetadataExists() throws {
        let path = try "\(XCTUnwrap(SystemAssemblyPaths.winMetadata))\\Windows.Foundation.winmd"
        XCTAssert(FileManager.default.fileExists(atPath: path))
    }
}