@testable import DotNetMetadata
import XCTest

/// Tests that the library is able to describe all kinds of types.
internal final class TypeTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        class Members
        {
            Struct DirectField;
            Struct[] ArrayField;
            unsafe Struct* PointerField;
            unsafe void* VoidPointerField;
            GenericClass<Struct> GenericInstanceField;
            U ReturnMethodGenericParam<U>() => default;
        }

        struct Struct {}

        class GenericClass<T>
        {
            T TypeGenericParamField;
        }
        """
    }

    private var membersTypeDefinition: TypeDefinition!
    private var structDefinition: TypeDefinition!
    private var genericClassDefinition: TypeDefinition!

    public override func setUpWithError() throws {
        try super.setUpWithError()
        membersTypeDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Members"))
        structDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Struct"))
        genericClassDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "GenericClass`1"))
    }

    public override func tearDown() {
        membersTypeDefinition = nil
        structDefinition = nil
        genericClassDefinition = nil
        super.tearDown()
    }

    public func testBoundType() throws {
        try XCTAssertEqual(
            XCTUnwrap(membersTypeDefinition.findField(name: "DirectField")).type,
            structDefinition.bindNode())
    }

    public func testArray() throws {
        try XCTAssertEqual(
            XCTUnwrap(membersTypeDefinition.findField(name: "ArrayField")).type,
            .array(of: structDefinition.bindNode()))
    }

    public func testPointer() throws {
        try XCTAssertEqual(
            XCTUnwrap(membersTypeDefinition.findField(name: "PointerField")).type,
            .pointer(to: structDefinition.bindNode()))
    }

    public func testVoidPointer() throws {
        try XCTAssertEqual(
            XCTUnwrap(membersTypeDefinition.findField(name: "VoidPointerField")).type,
            .pointer(to: nil))
    }

    public func testGenericInstance() throws {
        try XCTAssertEqual(
            XCTUnwrap(membersTypeDefinition.findField(name: "GenericInstanceField")).type,
            genericClassDefinition.bindNode(genericArgs: [ structDefinition.bindNode() ]))
    }

    public func testTypeGenericParams() throws {
        try XCTAssertEqual(
            XCTUnwrap(genericClassDefinition.findField(name: "TypeGenericParamField")).type,
            .genericParam(genericClassDefinition.genericParams[0]))
    }

    public func testMethodGenericParams() throws {

        let genericMethod = try XCTUnwrap(membersTypeDefinition.findMethod(name: "ReturnMethodGenericParam"))
        try XCTAssertEqual(genericMethod.returnType, .genericParam(genericMethod.genericParams[0]))
    }
}