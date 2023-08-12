@testable import DotNetXMLDocs
import XCTest

final class MemberKeyTests: XCTestCase {
    func testParseInvalid() throws {
        XCTAssertThrowsError(try MemberKey(parsing: ""))
        XCTAssertThrowsError(try MemberKey(parsing: "Hello"))
        XCTAssertThrowsError(try MemberKey(parsing: "K:Identifier"))
    }

    func testParseType() throws {
        XCTAssertEqual(try MemberKey(parsing: "T:TypeName"), .type(fullName: "TypeName"))
        XCTAssertEqual(try MemberKey(parsing: "T:Namespace.TypeName"), .type(fullName: "Namespace.TypeName"))
        XCTAssertEqual(try MemberKey(parsing: "T:Namespace.GenericTypeName`1"), .type(fullName: "Namespace.GenericTypeName`1"))
    }

    func testParseSimpleMember() throws {
        XCTAssertEqual(try MemberKey(parsing: "F:TypeName.Field"), .field(typeFullName: "TypeName", name: "Field"))
        XCTAssertEqual(try MemberKey(parsing: "P:Namespace.TypeName.Property"), .property(typeFullName: "Namespace.TypeName", name: "Property"))
        XCTAssertEqual(try MemberKey(parsing: "E:TypeName`1.Event"), .event(typeFullName: "TypeName`1", name: "Event"))
        XCTAssertEqual(try MemberKey(parsing: "M:TypeName.ParameterLessMethod"), .method(typeFullName: "TypeName", name: "ParameterLessMethod"))
        XCTAssertThrowsError(try MemberKey(parsing: "F:Identifier"))
    }
}