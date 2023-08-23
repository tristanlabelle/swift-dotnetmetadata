import XCTest
@testable import DotNetMetadata

final class MockMscorlibTests: XCTestCase {
    private static var context: AssemblyLoadContext!
    private static var mscorlib: Mscorlib!

    override class func setUp() {
        context = AssemblyLoadContext()
        let identity = AssemblyIdentity(name: Mscorlib.name, version: AssemblyVersion.all255)
        mscorlib = try? context.load(identity: identity) as? Mscorlib
    }

    override func setUpWithError() throws {
        try XCTSkipIf(Self.mscorlib == nil)
    }

    func testFindTypes() throws {
        XCTAssertNotNil(Self.mscorlib.findDefinedType(fullName: "System.Object"))
        XCTAssertNotNil(Self.mscorlib.findDefinedType(fullName: "System.Int32"))
        XCTAssertNotNil(Self.mscorlib.findDefinedType(fullName: "System.String"))
        XCTAssertNotNil(Self.mscorlib.findDefinedType(fullName: "System.Boolean"))
        XCTAssertNotNil(Self.mscorlib.findDefinedType(fullName: "System.Type"))
    }

    func testBaseTypes() throws {
        let specialTypes = Self.mscorlib.specialTypes!
        XCTAssertNil(specialTypes.object.base)
        XCTAssertEqual(specialTypes.string.base, specialTypes.object.bind())
        XCTAssertEqual(specialTypes.type.base, specialTypes.object.bind())
        XCTAssertEqual(specialTypes.valueType.base, specialTypes.object.bind())
        XCTAssertEqual(specialTypes.enum.base, specialTypes.valueType.bind())
        XCTAssertEqual(specialTypes.int32.base, specialTypes.valueType.bind())
        XCTAssertEqual(specialTypes.boolean.base, specialTypes.valueType.bind())
    }
}
