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

    func testParseInParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType)"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "DeclaringType"), name: "Method", params: [
                .init(type: .bound(nameWithoutGenericSuffix: "ParamType"))
            ]))
    }

    func testParseArrayParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType[])"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "DeclaringType"), name: "Method", params: [
                .init(type: .array(of: .bound(nameWithoutGenericSuffix: "ParamType")))
            ]))
    }

    func testParseOutParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType@)"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "DeclaringType"), name: "Method", params: [
                .init(type: .bound(nameWithoutGenericSuffix: "ParamType"), isByRef: true)
            ]))
    }

    func testParseGenericTypeParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType`1.Method(`0)"),
            .method(declaringType: .init(nameWithoutGenericSuffix: "DeclaringType", genericity: .unbound(arity: 1)), name: "Method", params: [
                .init(type: .genericParam(index: 0, kind: .type))
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