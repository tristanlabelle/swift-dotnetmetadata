@testable import DotNetXMLDocs
import XCTest
import FoundationXML

final class DocumentationParserTests: XCTestCase {
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

        var assemblyDocumentation = AssemblyDocumentation()
        DocumentationParser.feed(document: xmlDocument, sink: &assemblyDocumentation)

        XCTAssertEqual(assemblyDocumentation.name, "AssemblyName")
        XCTAssertEqual(assemblyDocumentation.members.count, 2)

        let typeEntry = try XCTUnwrap(assemblyDocumentation.members[MemberKey.type(fullName: "Namespace.TypeName`1")])
        XCTAssertEqual(typeEntry.summary, TextNode.plain("Summary"))
        XCTAssertEqual(typeEntry.typeParams, ["TypeParamName": TextNode.plain("TypeParamDesc")])

        let methodEntry = try XCTUnwrap(assemblyDocumentation.members[
            MemberKey.method(typeFullName: "Namespace.TypeName", name: "Method",
                params: [ .init(typeFullName: "Namespace2.TypeName2") ])])
        XCTAssertEqual(methodEntry.summary, TextNode.plain("Summary"))
        XCTAssertEqual(methodEntry.params, ["ParamName": TextNode.plain("ParamDesc")])
        XCTAssertEqual(methodEntry.returns, TextNode.plain("Returns"))
    }
}