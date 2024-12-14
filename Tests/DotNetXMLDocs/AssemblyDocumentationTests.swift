@testable import DotNetXMLDocs
import Testing
import FoundationXML

struct AssemblyDocumentationTests {
    @Test func testParseFullDocument() throws {
        let xmlDocument = try XMLDocument(xmlString: #"""
            <?xml version="1.0" encoding="utf-8"?>
            <doc>
                <assembly>
                    <name>AssemblyName</name>
                </assembly>
                <members>
                    <member name="T:TypeA">
                        <summary>Summary</summary>
                    </member>
                    <member name="T:TypeB">
                        <summary>Summary</summary>
                    </member>
                </members>
            </doc>
            """#)

        let assemblyDocumentation = try AssemblyDocumentation(parsing: xmlDocument)

        #expect(assemblyDocumentation.assemblyName == "AssemblyName")
        #expect(assemblyDocumentation.members.count == 2)

        #expect(assemblyDocumentation.members[.type(nameWithoutGenericArity: "TypeA")] != nil)
        #expect(assemblyDocumentation.members[.type(nameWithoutGenericArity: "TypeB")] != nil)
    }
}