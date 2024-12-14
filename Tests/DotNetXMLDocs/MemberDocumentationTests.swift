@testable import DotNetXMLDocs
import Testing
import FoundationXML

struct MemberDocumentationTests {
    private static func parse(xmlString: String) throws -> MemberDocumentation {
        let xmlDocument = try XMLDocument(xmlString: #"<?xml version="1.0" encoding="utf-8"?>"# + "\n" + xmlString)
        return MemberDocumentation(parsing: xmlDocument.rootElement()!)
    }

    @Test func testParseFields() throws {
        let memberDocumentation = try Self.parse(xmlString: #"""
            <member name="M:TypeName.FuncName">
                <summary>Summary</summary>
                <remarks>Remarks</remarks>
                <value>Value</value>
                <typeparam name="TypeParamName">TypeParamDesc</typeparam>
                <param name="ParamName">ParamDesc</param>
                <returns>Returns</returns>
                <exception cref="T:MyException">Exception</exception>
            </member>
            """#)

        #expect(memberDocumentation.summary == .plain("Summary"))
        #expect(memberDocumentation.remarks == .plain("Remarks"))
        #expect(memberDocumentation.value == .plain("Value"))
        #expect(memberDocumentation.typeParams == [.init(name: "TypeParamName", description: .plain("TypeParamDesc"))])
        #expect(memberDocumentation.params == [.init(name: "ParamName", description: .plain("ParamDesc"))])
        #expect(memberDocumentation.returns == .plain("Returns"))
        #expect(memberDocumentation.exceptions
            == [ .init(type: .init(nameWithoutGenericArity: "MyException"), description: .plain("Exception")) ])
    }
}