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
            .type(nameWithoutGenericArity: "Type"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "T:Namespace.Type"),
            .type(namespace: "Namespace", nameWithoutGenericArity: "Type"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "T:Namespace.GenericType`1"),
            .type(namespace: "Namespace", nameWithoutGenericArity: "GenericType", genericity: .unbound(arity: 1)))
    }

    func testParseParameterlessMember() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "F:Type.Field"),
            .field(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Field"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "P:Type.Property"),
            .property(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Property"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "E:Type.Event"),
            .event(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Event"))
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:Type.Method"),
            .method(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Method"))

        // Should have a type name followed by a member name
        XCTAssertThrowsError(
            try MemberDocumentationKey(parsing: "F:Identifier"))
    }

    func testParseGenericTypeMember() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:Namespace.Type`1.Method"),
            .method(declaringType: .init(namespace: "Namespace", nameWithoutGenericArity: "Type", genericity: .unbound(arity: 1)), name: "Method"))
    }

    func testParseInParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType)"),
            .method(declaringType: .init(nameWithoutGenericArity: "DeclaringType"), name: "Method", params: [
                .init(type: .bound(nameWithoutGenericArity: "ParamType"))
            ]))
    }

    func testParseArrayParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType[])"),
            .method(declaringType: .init(nameWithoutGenericArity: "DeclaringType"), name: "Method", params: [
                .init(type: .array(of: .bound(nameWithoutGenericArity: "ParamType")))
            ]))
    }

    func testParseOutParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType@)"),
            .method(declaringType: .init(nameWithoutGenericArity: "DeclaringType"), name: "Method", params: [
                .init(type: .bound(nameWithoutGenericArity: "ParamType"), isByRef: true)
            ]))
    }

    func testParseGenericTypeParam() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:DeclaringType`1.Method(`0)"),
            .method(declaringType: .init(nameWithoutGenericArity: "DeclaringType", genericity: .unbound(arity: 1)), name: "Method", params: [
                .init(type: .genericParam(index: 0, kind: .type))
            ]))
    }

    func testParseDefaultConstructor() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.#ctor"),
            .method(declaringType: .init(nameWithoutGenericArity: "TypeName"), name: MemberDocumentationKey.constructorName))

        _ = try MemberDocumentationKey(parsing: "M:Windows.AI.MachineLearning.LearningModelBinding.#ctor(Windows.AI.MachineLearning.LearningModelSession)")
    }

    func testParseNonDefaultConstructor() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.#ctor(System.Int32)"),
            .method(declaringType: .init(nameWithoutGenericArity: "TypeName"), name: MemberDocumentationKey.constructorName, params: [
                .init(type: .bound(namespace: "System", nameWithoutGenericArity: "Int32"))
            ]))
    }

    func testParseConversionOperator() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.op_Implicit()~ReturnType"),
            .method(
                declaringType: .init(nameWithoutGenericArity: "TypeName"),
                name: "op_Implicit",
                params: [],
                conversionTarget: .init(type: .bound(nameWithoutGenericArity: "ReturnType"))))
    }

    func testParseIndexer() throws {
        XCTAssertEqual(
            try MemberDocumentationKey(parsing: "M:TypeName.Property(System.Int32)"),
            .method(declaringType: .init(nameWithoutGenericArity: "TypeName"), name: "Property", params: [
                .init(type: .bound(namespace: "System", nameWithoutGenericArity: "Int32"))
            ]))
    }
}