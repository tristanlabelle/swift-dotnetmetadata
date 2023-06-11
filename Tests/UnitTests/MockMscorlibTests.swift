import XCTest
@testable import DotNetMDLogical

final class MockMscorlibTests: XCTestCase {
    private static var context: MetadataContext!
    private static var mscorlib: Mscorlib!

    override class func setUp() {
        struct AssemblyNotFound: Error {}
        context = MetadataContext(assemblyResolver: { _ in throw AssemblyNotFound() })
        mscorlib = try? context.loadAssembly(name: Mscorlib.name, version: .all255, culture: "") as? Mscorlib
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
        XCTAssertEqual(specialTypes.string.base, specialTypes.object.bindNonGeneric())
        XCTAssertEqual(specialTypes.type.base, specialTypes.object.bindNonGeneric())
        XCTAssertEqual(specialTypes.valueType.base, specialTypes.object.bindNonGeneric())
        XCTAssertEqual(specialTypes.enum.base, specialTypes.valueType.bindNonGeneric())
        XCTAssertEqual(specialTypes.int32.base, specialTypes.valueType.bindNonGeneric())
        XCTAssertEqual(specialTypes.boolean.base, specialTypes.valueType.bindNonGeneric())
    }
}
