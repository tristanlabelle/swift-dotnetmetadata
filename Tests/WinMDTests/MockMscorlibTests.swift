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
        let specialTypes = Self.mscorlib.specialTypes!
        XCTAssertNil(specialTypes.object.base)
        Self.AssertEqual(specialTypes.string.base, specialTypes.object)
        Self.AssertEqual(specialTypes.type.base, specialTypes.object)
        Self.AssertEqual(specialTypes.valueType.base, specialTypes.object)
        Self.AssertEqual(specialTypes.enum.base, specialTypes.valueType)
        Self.AssertEqual(specialTypes.int32.base, specialTypes.valueType)
        Self.AssertEqual(specialTypes.boolean.base, specialTypes.valueType)
    }

    static func AssertEqual(_ lhs: Type?, _ rhs: TypeDefinition?) {
        switch (lhs, rhs) {
        case (.none, .none):
            return
        case (.some(.simple(let lhs)), .some(let rhs)):
            XCTAssertIdentical(lhs, rhs)
        default:
            XCTFail("Expected \(String(describing: lhs)) to equal \(String(describing: rhs))")
        }
    }
}
