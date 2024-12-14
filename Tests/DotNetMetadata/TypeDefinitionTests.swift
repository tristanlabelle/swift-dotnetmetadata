@testable import DotNetMetadata
import Testing

internal struct TypeDefinitionTests {
    @Test func testTypeKinds() throws {
        let compilation = try CSharpCompilation(code:
        """
        interface Interface {}
        class Class {}
        delegate void Delegate();
        enum Enum {}
        struct Struct {}
        """)

        let assembly = compilation.assembly
        #expect(try assembly.resolveTypeDefinition(fullName: "Interface") is InterfaceDefinition)
        #expect(try assembly.resolveTypeDefinition(fullName: "Class") is ClassDefinition)
        #expect(try assembly.resolveTypeDefinition(fullName: "Delegate") is DelegateDefinition)
        #expect(try assembly.resolveTypeDefinition(fullName: "Enum") is EnumDefinition)
        #expect(try assembly.resolveTypeDefinition(fullName: "Struct") is StructDefinition)
    }

    @Test func testStructuralRelationships() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Generic<T> {}
        class Base {}
        class Derived : Base {}
        interface Interface {}
        class Implementing : Interface {}
        class Enclosing { class Nested {} }
        """)

        let assembly = compilation.assembly

        // Base/derived
        let base = try #require(try assembly.resolveTypeDefinition(fullName: "Base"))
        let derived = try #require(try assembly.resolveTypeDefinition(fullName: "Derived"))
        #expect(try #require(try derived.base) == base.bindType())
        #expect(try #require(try base.base) == base.context.coreLibrary.systemObject.bindType())

        // Interface implementation
        let interface = try #require(try assembly.resolveTypeDefinition(fullName: "Interface"))
        let implementing = try #require(try assembly.resolveTypeDefinition(fullName: "Implementing"))
        #expect(try #require(implementing.baseInterfaces.first).interface.asBoundType == interface.bindType())

        // Nesting
        let enclosing = try #require(try assembly.resolveTypeDefinition(fullName: "Enclosing"))
        let nested = try #require(try assembly.resolveTypeDefinition(fullName: "Enclosing/Nested"))
        #expect(try #require(try nested.enclosingType) == enclosing)
        #expect(try #require(try enclosing.nestedTypes.first) == nested)
    }

    @Test func testVisibility() throws {
        let compilation = try CSharpCompilation(code:
        """
        internal class Internal {}
        public class Public {}
        class NestedVisibility
        {
            private class Private {}
            protected class Protected {}
            internal class Internal {}
            private protected class PrivateProtected {}
            protected internal class ProtectedInternal {}
            public class Public {}
        }
        """)

        func assertTypeVisibility(_ name: String, _ visibility: Visibility) throws {
            let typeDefinition = try #require(try compilation.assembly.resolveTypeDefinition(fullName: name))
            #expect(typeDefinition.visibility == visibility)
        }

        try assertTypeVisibility("Internal", .assembly)
        try assertTypeVisibility("Public", .public)
        try assertTypeVisibility("NestedVisibility/Private", .private)
        try assertTypeVisibility("NestedVisibility/Protected", .family)
        try assertTypeVisibility("NestedVisibility/Internal", .assembly)
        try assertTypeVisibility("NestedVisibility/PrivateProtected", .familyAndAssembly)
        try assertTypeVisibility("NestedVisibility/ProtectedInternal", .familyOrAssembly)
        try assertTypeVisibility("NestedVisibility/Public", .public)
    }

    @Test func testModifiers() throws {
        let compilation = try CSharpCompilation(code:
        """
        class Open {}
        sealed class Sealed {}
        abstract class Abstract {}
        static class Static {}
        """)

        func assertTypeModifiers(_ name: String, abstract: Bool = false, sealed: Bool = false, static: Bool = false) throws {
            let typeDefinition = try #require(compilation.assembly.resolveTypeDefinition(fullName: name) as? ClassDefinition)
            #expect(typeDefinition.isAbstract == abstract)
            #expect(typeDefinition.isSealed == sealed)
            #expect(typeDefinition.isStatic == `static`)
        }

        try assertTypeModifiers("Open")
        try assertTypeModifiers("Sealed", sealed: true)
        try assertTypeModifiers("Abstract", abstract: true)
        try assertTypeModifiers("Static", abstract: true, sealed: true, static: true)
    }

    @Test func testStructLayout() throws {
        let compilation = try CSharpCompilation(code:
        """
        using System.Runtime.InteropServices;

        [StructLayout(LayoutKind.Auto)]
        struct Auto {}

        [StructLayout(LayoutKind.Sequential, Pack = 2, Size = 24)]
        struct Sequential {}

        [StructLayout(LayoutKind.Explicit, Size = 24)]
        struct Explicit
        {
            [FieldOffset(16)]
            int A;
            [FieldOffset(16)]
            float B;
        }
        """)

        let assembly = compilation.assembly
        let auto = try #require(try assembly.resolveTypeDefinition(fullName: "Auto"))
        #expect(auto.layout == .auto)

        let sequential = try #require(try assembly.resolveTypeDefinition(fullName: "Sequential"))
        #expect(sequential.layout == .sequential(pack: 2, minSize: 24))

        let explicit = try #require(try assembly.resolveTypeDefinition(fullName: "Explicit"))
        #expect(explicit.layout == .explicit(minSize: 24))
        #expect(explicit.findField(name: "A")?.explicitOffset == 16)
        #expect(explicit.findField(name: "B")?.explicitOffset == 16)
    }
}