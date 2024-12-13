@testable import DotNetMetadata
import Testing

/// Tests that the library is able to describe all kinds of types.
internal final class TypeTests {
    private var compilation: CSharpCompilation
    private var assembly: Assembly { compilation.assembly }
    private var membersTypeDefinition: TypeDefinition
    private var structDefinition: TypeDefinition
    private var genericClassDefinition: TypeDefinition

    init() throws {
        compilation = try CSharpCompilation(code: 
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
        """)

        let assembly = compilation.assembly
        membersTypeDefinition = try #require(assembly.resolveTypeDefinition(fullName: "Members"))
        structDefinition = try #require(assembly.resolveTypeDefinition(fullName: "Struct"))
        genericClassDefinition = try #require(assembly.resolveTypeDefinition(fullName: "GenericClass`1"))
    }

    @Test func testBoundType() throws {
        let field = try #require(membersTypeDefinition.findField(name: "DirectField"))
        #expect(field.type == structDefinition.bindNode())
    }

    @Test func testArray() throws {
        let field = try #require(membersTypeDefinition.findField(name: "ArrayField"))
        #expect(field.type == .array(of: structDefinition.bindNode()))
    }

    @Test func testPointer() throws {
        let field = try #require(membersTypeDefinition.findField(name: "PointerField"))
        #expect(field.type == .pointer(to: structDefinition.bindNode()))
    }

    @Test func testVoidPointer() throws {
        let field = try #require(membersTypeDefinition.findField(name: "VoidPointerField"))
        #expect(field.type == .pointer(to: nil))
    }

    @Test func testGenericInstance() throws {
        let field = try #require(membersTypeDefinition.findField(name: "GenericInstanceField"))
        #expect(field.type == genericClassDefinition.bindNode(genericArgs: [ structDefinition.bindNode() ]))
    }

    @Test func testTypeGenericParams() throws {
        let field = try #require(genericClassDefinition.findField(name: "TypeGenericParamField"))
        #expect(field.type == .genericParam(genericClassDefinition.genericParams[0]))
    }

    @Test func testMethodGenericParams() throws {
        let genericMethod = try #require(membersTypeDefinition.findMethod(name: "ReturnMethodGenericParam"))
        #expect(try genericMethod.returnType == .genericParam(genericMethod.genericParams[0]))
    }
}