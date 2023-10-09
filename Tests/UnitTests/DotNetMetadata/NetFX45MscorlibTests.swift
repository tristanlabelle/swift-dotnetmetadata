@testable import DotNetMetadata
import XCTest

final class NetFX45MscorlibTests: XCTestCase {
    internal static var context: AssemblyLoadContext!
    internal static var assembly: Assembly!

    override class func setUp() {
        guard let framework4Path = SystemAssemblyPaths.framework4 else { return }

        context = AssemblyLoadContext()
        assembly = try? context.load(path: "\(framework4Path)\\\(Mscorlib.filename)")
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.assembly == nil)
    }

    func testIsMscorlib() throws {
        XCTAssertNotNil(Self.assembly as? Mscorlib)
    }

    internal var specialTypes: Mscorlib.SpecialTypes {
        (Self.assembly as! Mscorlib).specialTypes
    }

    func testTypeLookup() throws {
        XCTAssertNotNil(Self.assembly.findDefinedType(fullName: "System.Object"))
    }
}
