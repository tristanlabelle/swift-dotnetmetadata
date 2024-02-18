@testable import DotNetMetadata
import XCTest

final class NetFX45MscorlibTests: XCTestCase {
    internal static var context: AssemblyLoadContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        guard let mscorlibPath = SystemAssemblies.DotNetFramework4.mscorlibPath else { return }

        context = AssemblyLoadContext()
        assembly = try? context.load(path: mscorlibPath)
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.assembly == nil)
    }

    internal var coreLibrary: CoreLibrary { get throws { try Self.context.coreLibrary } }

    func testTypeLookup() throws {
        XCTAssertNotNil(try Self.assembly.resolveTypeDefinition(fullName: "System.Object"))
    }
}
