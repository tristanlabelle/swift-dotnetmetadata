@testable import DotNetMetadata
import XCTest

internal final class PropertyTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        struct PropertyType {}
        abstract class Properties {
            public abstract PropertyType PublicAbstractInstanceGetSet { get; set; }
            private static PropertyType PrivateStaticGet { get { return new PropertyType(); } }
        }
        """
    }

    private var typeDefinition: TypeDefinition!
    private var publicAbstractInstanceGetSetProperty: Property!
    private var privateStaticGetProperty: Property!

    public override func setUpWithError() throws {
        try super.setUpWithError()
        typeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Properties"))
        publicAbstractInstanceGetSetProperty = try XCTUnwrap(typeDefinition.findProperty(name: "PublicAbstractInstanceGetSet"))
        privateStaticGetProperty = try XCTUnwrap(typeDefinition.findProperty(name: "PrivateStaticGet"))
    }

    public override func tearDown() {
        typeDefinition = nil
        publicAbstractInstanceGetSetProperty = nil
        privateStaticGetProperty = nil
        super.tearDown()
    }

    public func testEnumeration() throws {
        XCTAssertEqual(
            typeDefinition.properties.map { $0.name },
            ["PublicAbstractInstanceGetSet", "PrivateStaticGet"])
    }

    public func testName() throws {
        XCTAssertEqual(publicAbstractInstanceGetSetProperty.name, "PublicAbstractInstanceGetSet")
    }

    public func testType() throws {
        try XCTAssertEqual(
            XCTUnwrap(publicAbstractInstanceGetSetProperty.type.asDefinition),
            XCTUnwrap(assembly.resolveTypeDefinition(fullName: "PropertyType")))
    }

    public func testAccessors() throws {
        try XCTAssertNotNil(publicAbstractInstanceGetSetProperty.getter)
        try XCTAssertNotNil(publicAbstractInstanceGetSetProperty.setter)
        try XCTAssertNotNil(privateStaticGetProperty.getter)
        try XCTAssertNil(privateStaticGetProperty.setter)
    }
}