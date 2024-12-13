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
        typeDefinition = try #require(assembly.resolveTypeDefinition(fullName: "Properties"))
        publicAbstractInstanceGetSetProperty = try #require(typeDefinition.findProperty(name: "PublicAbstractInstanceGetSet"))
        privateStaticGetProperty = try #require(typeDefinition.findProperty(name: "PrivateStaticGet"))
    }

    @Test func testEnumeration() throws {
        #expect(
            typeDefinition.properties.map { $0.name } == ["PublicAbstractInstanceGetSet", "PrivateStaticGet"])
    }

    @Test func testName() throws {
        #expect(publicAbstractInstanceGetSetProperty.name == "PublicAbstractInstanceGetSet")
    }

    @Test func testType() throws {
        #expect(
            #require(publicAbstractInstanceGetSetProperty.type.asDefinition)
            == #require(assembly.resolveTypeDefinition(fullName: "PropertyType")))
    }

    @Test func testAccessors() throws {
        #expect(publicAbstractInstanceGetSetProperty.getter != nil)
        #expect(publicAbstractInstanceGetSetProperty.setter != nil)
        #expect(privateStaticGetProperty.getter != nil)
        #expect(privateStaticGetProperty.setter == nil)
    }
}