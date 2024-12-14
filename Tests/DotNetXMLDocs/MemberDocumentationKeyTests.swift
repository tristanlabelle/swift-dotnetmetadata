@testable import DotNetXMLDocs
import Testing

struct MemberDocumentationKeyTests {
    @Test func testParseInvalid() throws {
        #expect(throws: (any Error).self) { try MemberDocumentationKey(parsing: "") }
        #expect(throws: (any Error).self) { try MemberDocumentationKey(parsing: "Hello") }
        #expect(throws: (any Error).self) { try MemberDocumentationKey(parsing: "K:Identifier") }
    }

    @Test func testParseType() throws {
        #expect(try MemberDocumentationKey(parsing: "T:Type")
            == .type(nameWithoutGenericArity: "Type"))
        #expect(try MemberDocumentationKey(parsing: "T:Namespace.Type")
            == .type(namespace: "Namespace", nameWithoutGenericArity: "Type"))
        #expect(try MemberDocumentationKey(parsing: "T:Namespace.GenericType`1")
            == .type(namespace: "Namespace", nameWithoutGenericArity: "GenericType", genericity: .unbound(arity: 1)))
    }

    @Test func testParseParameterlessMember() throws {
        #expect(try MemberDocumentationKey(parsing: "F:Type.Field")
            == .field(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Field"))
        #expect(try MemberDocumentationKey(parsing: "P:Type.Property")
            == .property(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Property"))
        #expect(try MemberDocumentationKey(parsing: "E:Type.Event")
            == .event(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Event"))
        #expect(try MemberDocumentationKey(parsing: "M:Type.Method")
            == .method(declaringType: .init(nameWithoutGenericArity: "Type"), name: "Method"))

        // Should have a type name followed by a member name
        #expect(throws: (any Error).self) { try MemberDocumentationKey(parsing: "F:Identifier") }
    }

    @Test func testParseGenericTypeMember() throws {
        #expect(try MemberDocumentationKey(parsing: "M:Namespace.Type`1.Method")
            == .method(
                declaringType: .init(namespace: "Namespace", nameWithoutGenericArity: "Type", genericity: .unbound(arity: 1)),
                name: "Method"))
    }

    @Test func testParseInParam() throws {
        #expect(try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType)")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "DeclaringType"),
                name: "Method",
                params: [ .init(type: .bound(nameWithoutGenericArity: "ParamType")) ]))
    }

    @Test func testParseArrayParam() throws {
        #expect(try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType[])")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "DeclaringType"),
                name: "Method",
                params: [ .init(type: .array(of: .bound(nameWithoutGenericArity: "ParamType"))) ]))
    }

    @Test func testParseOutParam() throws {
        #expect(try MemberDocumentationKey(parsing: "M:DeclaringType.Method(ParamType@)")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "DeclaringType"),
                name: "Method",
                params: [ .init(type: .bound(nameWithoutGenericArity: "ParamType"), isByRef: true) ]))
    }

    @Test func testParseGenericTypeParam() throws {
        #expect(try MemberDocumentationKey(parsing: "M:DeclaringType`1.Method(`0)")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "DeclaringType", genericity: .unbound(arity: 1)),
                name: "Method",
                params: [ .init(type: .genericParam(index: 0, kind: .type)) ]))
    }

    @Test func testParseDefaultConstructor() throws {
        #expect(try MemberDocumentationKey(parsing: "M:TypeName.#ctor")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "TypeName"),
                name: MemberDocumentationKey.constructorName))

        _ = try MemberDocumentationKey(parsing: "M:Windows.AI.MachineLearning.LearningModelBinding.#ctor(Windows.AI.MachineLearning.LearningModelSession)")
    }

    @Test func testParseNonDefaultConstructor() throws {
        #expect(try MemberDocumentationKey(parsing: "M:TypeName.#ctor(System.Int32)")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "TypeName"),
                name: MemberDocumentationKey.constructorName,
                params: [ .init(type: .bound(namespace: "System", nameWithoutGenericArity: "Int32")) ]))
    }

    @Test func testParseConversionOperator() throws {
        #expect(try MemberDocumentationKey(parsing: "M:TypeName.op_Implicit()~ReturnType")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "TypeName"),
                name: "op_Implicit",
                params: [],
                conversionTarget: .init(type: .bound(nameWithoutGenericArity: "ReturnType"))))
    }

    @Test func testParseIndexer() throws {
        #expect(try MemberDocumentationKey(parsing: "M:TypeName.Property(System.Int32)")
            == .method(
                declaringType: .init(nameWithoutGenericArity: "TypeName"),
                name: "Property",
                params: [ .init(type: .bound(namespace: "System", nameWithoutGenericArity: "Int32")) ]))
    }
}