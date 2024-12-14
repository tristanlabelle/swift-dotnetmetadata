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
        membersTypeDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Members"))
        structDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Struct"))
        genericClassDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "GenericClass`1"))
    }

    @Test func testBoundType() throws {
        let field = try #require(try membersTypeDefinition.findField(name: "DirectField"))
        #expect(try field.type == structDefinition.bindNode())
    }

    @Test func testArray() throws {
        let field = try #require(try membersTypeDefinition.findField(name: "ArrayField"))
        #expect(try field.type == .array(of: structDefinition.bindNode()))
    }

    @Test func testPointer() throws {
        let field = try #require(try membersTypeDefinition.findField(name: "PointerField"))
        #expect(try field.type == .pointer(to: structDefinition.bindNode()))
    }

    @Test func testVoidPointer() throws {
        let field = try #require(try membersTypeDefinition.findField(name: "VoidPointerField"))
        #expect(try field.type == .pointer(to: nil))
    }

    @Test func testGenericInstance() throws {
        let field = try #require(try membersTypeDefinition.findField(name: "GenericInstanceField"))
        #expect(try field.type == genericClassDefinition.bindNode(genericArgs: [ structDefinition.bindNode() ]))
    }

    @Test func testTypeGenericParams() throws {
        let field = try #require(try genericClassDefinition.findField(name: "TypeGenericParamField"))
        #expect(try field.type == .genericParam(genericClassDefinition.genericParams[0]))
    }

    @Test func testMethodGenericParams() throws {
        let genericMethod = try #require(try membersTypeDefinition.findMethod(name: "ReturnMethodGenericParam"))
        #expect(try genericMethod.returnType == .genericParam(genericMethod.genericParams[0]))
    }
}