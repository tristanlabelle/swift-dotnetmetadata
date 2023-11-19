@testable import DotNetXMLDocs
import XCTest

final class MemberDocumentationKeyTests: XCTestCase {
    func testParseInvalid() throws {
        XCTAssertThrowsError(try MemberDocumentationKey(parsing: ""))
        XCTAssertThrowsError(try MemberDocumentationKey(parsing: "Hello"))
        XCTAssertThrowsError(try MemberDocumentationKey(parsing: "K:Identifier"))
    }

    func testParseType() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "T:Type"),
            .type(nameWithoutGenericSuffix: "Type"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "T:Namespace.Type"),
            .type(namespace: "Namespace", nameWithoutGenericSuffix: "Type"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "T:Namespace.GenericType`1"),
            .type(namespace: "Namespace", nameWithoutGenericSuffix: "GenericType", genericity: .unbound(arity: 1)))
    }

    func testParseParameterlessMember() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "F:Type.Field"),
            .field(declaringType: .init(nameWithoutGenericSuffix: "Type"), name: "Field"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "P:Type.Property"),
            .property(declaringType: .init(nameWithoutGenericSuffix: "Type"), name: "Property"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "E:Type.Event"),
            .event(declaringType: .init(nameWithoutGenericSuffix: "Type"), name: "Event"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:Type.Method"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "Type"), name: "Method"))

        // Should have a type name followed by a member name
        XCTAssertThrowsError(
            try MemberDocumentationKey(parsing: "F:Identifier"))
    }

    func testParseGenericTypeMember() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:Namespace.Type`1.Method"),
            .method(declaringType: .init(namespace: "Namespace", nameWithoutGenericSuffix: "Type", genericity: .unbound(arity: 1)), name: "Method"))
    }

    func testParseMethod() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.Method(InParamType,OutParamType@)"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "TypeName"), name: "Method", params: [
                .init(type: .bound(nameWithoutGenericSuffix: "InParamType")),
                .init(type: .bound(nameWithoutGenericSuffix: "OutParamType"), isByRef: true)
            ]))
    }

    func testParseConstructor() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.#ctor"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "TypeName"), name: MemberDocumentationKey.constructorName))
    }

    func testParseConversionOperator() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.op_Implicit()~ReturnType"),
            .method(
                declaringType: .init(nameWithoutGenericSuffix: "TypeName"),
                name: "op_Implicit",
                params: [],
                conversionTarget: .init(type: .bound(nameWithoutGenericSuffix: "ReturnType"))))
    }

    func testParseIndexer() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.Property(System.Int32)"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "TypeName"), name: "Property", params: [
                .init(type: .bound(namespace: "System", nameWithoutGenericSuffix: "Int32"))
            ]))
    }
}