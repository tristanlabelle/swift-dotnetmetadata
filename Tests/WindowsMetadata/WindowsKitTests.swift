@testable import WindowsMetadata
import XCTest

final class WindowsKitTests: XCTestCase {
    public func testRead() throws {
        let kits = try WindowsKit.getInstalled()
        try XCTSkipIf(kits.isEmpty, "No Windows Kits found")
        let applicationPlatform = try kits[0].readApplicationPlatform()
        XCTAssertNotNil(applicationPlatform.apiContracts["Windows.Foundation.UniversalApiContract"])
    }
}