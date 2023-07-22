import Foundation
import XCTest
@testable import DotNetMD

final class WinMetadataTests: XCTestCase {
    internal static var context: MetadataContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        let windowsPath = ProcessInfo.processInfo.environment["windir"]
            ?? ProcessInfo.processInfo.environment["SystemRoot"]
            ?? #"C:\Windows"#
        let url = URL(fileURLWithPath: "\(windowsPath)\\System32\\WinMetadata\\Windows.Foundation.winmd")

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
