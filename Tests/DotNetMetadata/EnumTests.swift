@testable import DotNetMetadata
import Testing

internal final class EnumTests {
    private var compilation: CSharpCompilation
    private var assembly: Assembly { compilation.assembly }

    init() throws {
        compilation = try CSharpCompilation(code: 
        """
        enum MyEnum { A = 1, B = 2 }
        [System.Flags] enum MyFlagsEnum { None = 0, A = 1 }
        enum MyShortEnum: short { A = 42 }
        """)
    }

    @Test func testEnumerantNames() throws {
        let enumDefinition = try #require(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition)
        #expect(enumDefinition.fields.filter { $0.isStatic }.map { $0.name }.sorted() == ["A", "B"])
    }

    @Test func testUnderlyingType() throws {
        #expect(
            #require(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition).underlyingType.fullName == "System.Int32")
        #expect(
            #require(assembly.resolveTypeDefinition(fullName: "MyShortEnum") as? EnumDefinition).underlyingType.fullName == "System.Int16")
    }

    @Test func testEnumerantValues() throws {
        let enumDefinition = try #require(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition)
        #expect(try #require(#require(enumDefinition.findField(name: "A")).literalValue) == .int32(1))
        #expect(try #require(#require(enumDefinition.findField(name: "B")).literalValue) == .int32(2))

        let shortEnumDefinition = try #require(assembly.resolveTypeDefinition(fullName: "MyShortEnum") as? EnumDefinition)
        #expect(try #require(#require(shortEnumDefinition.findField(name: "A")).literalValue) == .int16(42))
    }

    @Test func testIsFlags() throws {
        #expect(!#require(assembly.resolveTypeDefinition(fullName: "MyEnum") as? EnumDefinition).isFlags)
        #expect(#require(assembly.resolveTypeDefinition(fullName: "MyFlagsEnum") as? EnumDefinition).isFlags)
    }
}