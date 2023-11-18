@testable import DotNetXMLDocs
import XCTest
import FoundationXML

final class MemberDocumentationTests: XCTestCase {
    private static func parse(xmlString: String) throws -> MemberDocumentation {
        let xmlDocument = try XMLDocument(xmlString: #"<?xml version="1.0" encoding="utf-8"?>"# + "\n" + xmlString)
        return MemberDocumentation(parsing: xmlDocument.rootElement()!)
    }

    func testParseFields() throws {
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

        XCTAssertEqual(memberDocumentation.summary, .plain("Summary"))
        XCTAssertEqual(memberDocumentation.remarks, .plain("Remarks"))
        XCTAssertEqual(memberDocumentation.value, .plain("Value"))
        XCTAssertEqual(memberDocumentation.typeParams, [.init(name: "TypeParamName", description: .plain("TypeParamDesc"))])
        XCTAssertEqual(memberDocumentation.params, [.init(name: "ParamName", description: .plain("ParamDesc"))])
        XCTAssertEqual(memberDocumentation.returns, .plain("Returns"))
        XCTAssertEqual(memberDocumentation.exceptions, [.init(type: .type(fullName: "MyException"), description: .plain("Exception"))])
    }

    func testParseIgnoresEmptyTags() throws {
        let memberDocumentation = try Self.parse(xmlString: #"""
            <member name="M:TypeName.FuncName">
                <summary>  </summary>
                <remarks>
                </remarks>
            </member>
            """#)

        XCTAssertNil(memberDocumentation.summary)
        XCTAssertNil(memberDocumentation.remarks)
    }
}