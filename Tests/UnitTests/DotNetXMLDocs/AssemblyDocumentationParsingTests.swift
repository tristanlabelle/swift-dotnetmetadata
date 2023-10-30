@testable import DotNetXMLDocs
import XCTest
import FoundationXML

final class AssemblyDocumentationParsingTests: XCTestCase {
    func testParseFullDocument() throws {
        let xmlDocument = try XMLDocument(xmlString: #"""
            <?xml version="1.0" encoding="utf-8"?>
            <doc>
                <assembly>
                    <name>AssemblyName</name>
                </assembly>
                <members>
                    <member name="T:Namespace.TypeName`1">
                        <summary>Summary</summary>
                        <typeparam name="TypeParamName">TypeParamDesc</typeparam>
                    </member>
                    <member name="M:Namespace.TypeName.Method(Namespace2.TypeName2)">
                        <summary>Summary</summary>
                        <param name="ParamName">ParamDesc</param>
                        <returns>Returns</returns>
                    </member>
                </members>
            </doc>
            """#)

        let assemblyDocumentation = try AssemblyDocumentation(parsing: xmlDocument)

        XCTAssertEqual(assemblyDocumentation.assemblyName, "AssemblyName")
        XCTAssertEqual(assemblyDocumentation.members.count, 2)

        let typeEntry = try XCTUnwrap(assemblyDocumentation.members[.type(fullName: "Namespace.TypeName`1")])
        XCTAssertEqual(typeEntry.summary, .plain("Summary"))
        XCTAssertEqual(typeEntry.typeParams, ["TypeParamName": .plain("TypeParamDesc")])

        let methodEntry = try XCTUnwrap(assemblyDocumentation.members[
            .method(declaringType: "Namespace.TypeName", name: "Method",
                params: [ .init(typeFullName: "Namespace2.TypeName2") ])])
        XCTAssertEqual(methodEntry.summary, .plain("Summary"))
        XCTAssertEqual(methodEntry.params, ["ParamName": .plain("ParamDesc")])
        XCTAssertEqual(methodEntry.returns, .plain("Returns"))
    }
}