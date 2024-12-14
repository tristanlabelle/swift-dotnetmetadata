@testable import DotNetMetadata
import Testing

internal final class PropertyTests {
    private var compilation: CSharpCompilation
    private var assembly: Assembly { compilation.assembly }
    private var typeDefinition: TypeDefinition
    private var publicAbstractInstanceGetSetProperty: Property
    private var privateStaticGetProperty: Property

    init() throws {
        compilation = try CSharpCompilation(code: 
        """
        struct PropertyType {}
        abstract class Properties {
            public abstract PropertyType PublicAbstractInstanceGetSet { get; set; }
            private static PropertyType PrivateStaticGet { get { return new PropertyType(); } }
        }
        """)

        let assembly = compilation.assembly
        typeDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Properties"))
        publicAbstractInstanceGetSetProperty = try #require(try typeDefinition.findProperty(name: "PublicAbstractInstanceGetSet"))
        privateStaticGetProperty = try #require(try typeDefinition.findProperty(name: "PrivateStaticGet"))
    }

    @Test func testEnumeration() throws {
        #expect(
            typeDefinition.properties.map { $0.name } == ["PublicAbstractInstanceGetSet", "PrivateStaticGet"])
    }

    @Test func testName() throws {
        #expect(publicAbstractInstanceGetSetProperty.name == "PublicAbstractInstanceGetSet")
    }

    @Test func testType() throws {
        #expect(try #require(publicAbstractInstanceGetSetProperty.type.asDefinition)
            == #require(try assembly.resolveTypeDefinition(fullName: "PropertyType")))
    }

    @Test func testAccessors() throws {
        #expect(try publicAbstractInstanceGetSetProperty.getter != nil)
        #expect(try publicAbstractInstanceGetSetProperty.setter != nil)
        #expect(try privateStaticGetProperty.getter != nil)
        #expect(try privateStaticGetProperty.setter == nil)
    }
}