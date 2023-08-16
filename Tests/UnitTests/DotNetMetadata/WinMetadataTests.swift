@testable import DotNetMetadata
import XCTest

final class WinMetadataTests: XCTestCase {
    internal static var context: MetadataContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        guard let winMetadataPath = SystemAssemblyPaths.winMetadata else { return }
        let url = URL(fileURLWithPath: "\(winMetadataPath)\\Windows.Foundation.winmd")

        context = MetadataContext()
        assembly = try? context.loadAssembly(url: url)
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.assembly == nil, "System Windows.Foundation.winmd not found")
    }

    func testMscorlibTypeReference() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "Windows.Foundation.Point")?.base?.definition.fullName,
            "System.ValueType")
    }
}
