@testable import DotNetXMLDocs
import XCTest
import FoundationXML

final class AssemblyDocumentationTests: XCTestCase {
    func testParseFullDocument() throws {
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

        XCTAssertEqual(assemblyDocumentation.assemblyName, "AssemblyName")
        XCTAssertEqual(assemblyDocumentation.members.count, 2)

        XCTAssertNotNil(assemblyDocumentation.members[.type(nameWithoutGenericSuffix: "TypeA")])
        XCTAssertNotNil(assemblyDocumentation.members[.type(nameWithoutGenericSuffix: "TypeB")])
    }
}