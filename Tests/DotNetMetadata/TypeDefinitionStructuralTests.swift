@testable import DotNetMetadata
import XCTest

internal final class TypeDefinitionStructuralTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        interface Interface {}
        class Class {}
        delegate void Delegate();
        enum Enum {}
        struct Struct {}

        class GenericClass<T> {}
        class DerivedClass : Class {}
        class ImplementingClass : Interface {}
        class EnclosingClass { class NestedClass {} }
        """
    }

    public func testTypeKinds() throws {
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Interface") as? InterfaceDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Class") as? ClassDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Delegate") as? DelegateDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Enum") as? EnumDefinition)
        try XCTAssertNotNil(assembly.resolveTypeDefinition(fullName: "Struct") as? StructDefinition)
    }

    public func testBaseClass() throws {
        let `class` = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Class"))
        let derivedClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "DerivedClass"))
        try XCTAssertEqual(XCTUnwrap(derivedClass.base), `class`.bindType())
        try XCTAssertEqual(XCTUnwrap(`class`.base), `class`.context.coreLibrary.systemObject.bindType())
    }

    public func testImplementedInterface() throws {
        let implementingClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "ImplementingClass"))
        try XCTAssertEqual(
            XCTUnwrap(implementingClass.baseInterfaces.first).interface.asBoundType,
            XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Interface")).bindType())
    }

    public func testClassNesting() throws {
        let enclosingClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "EnclosingClass"))
        let nestedClass = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "EnclosingClass/NestedClass"))
        try XCTAssertEqual(XCTUnwrap(nestedClass.enclosingType), enclosingClass)
        try XCTAssertEqual(XCTUnwrap(enclosingClass.nestedTypes.first), nestedClass)
    }
}