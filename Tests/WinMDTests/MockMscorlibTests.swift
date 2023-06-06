import Foundation
import XCTest
@testable import WinMDGraph

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
        XCTAssertNotNil(Self.mscorlib.findTypeDefinition(fullName: "System.Object"))
        XCTAssertNotNil(Self.mscorlib.findTypeDefinition(fullName: "System.Int32"))
        XCTAssertNotNil(Self.mscorlib.findTypeDefinition(fullName: "System.String"))
        XCTAssertNotNil(Self.mscorlib.findTypeDefinition(fullName: "System.Boolean"))
        XCTAssertNotNil(Self.mscorlib.findTypeDefinition(fullName: "System.Type"))
    }

    func testBaseTypes() throws {
        XCTAssertNil(Self.mscorlib.specialTypes.object.base)
        XCTAssertIdentical(Self.mscorlib.specialTypes.string.base, Self.mscorlib.specialTypes.object)
        XCTAssertIdentical(Self.mscorlib.specialTypes.type.base, Self.mscorlib.specialTypes.object)
        XCTAssertIdentical(Self.mscorlib.specialTypes.valueType.base, Self.mscorlib.specialTypes.object)
        XCTAssertIdentical(Self.mscorlib.specialTypes.enum.base, Self.mscorlib.specialTypes.valueType)
        XCTAssertIdentical(Self.mscorlib.specialTypes.int32.base, Self.mscorlib.specialTypes.valueType)
        XCTAssertIdentical(Self.mscorlib.specialTypes.boolean.base, Self.mscorlib.specialTypes.valueType)
    }
}
