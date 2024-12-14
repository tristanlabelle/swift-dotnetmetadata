@testable import DotNetMetadata
import Testing

final class AttributeApplicationTests {
    private var compilation: CSharpCompilation
    private var assembly: Assembly { compilation.assembly }

    init() throws {
        compilation = try CSharpCompilation(code: 
        """
        // Must precede all other declarations
        [assembly: MyAttribute(System.AttributeTargets.Assembly)]
        [module: MyAttribute(System.AttributeTargets.Module)]

        [System.AttributeUsage(System.AttributeTargets.All)]
        class MyAttributeAttribute: System.Attribute
        {
            public MyAttributeAttribute(System.AttributeTargets target) {}
        }

        [MyAttribute(System.AttributeTargets.Delegate)] delegate void Delegate();
        [MyAttribute(System.AttributeTargets.Enum)] enum Enum {}
        [MyAttribute(System.AttributeTargets.Interface)] interface Interface {}
        [MyAttribute(System.AttributeTargets.Struct)] struct Struct {}
        [MyAttribute(System.AttributeTargets.Class)] class Class {}

        class Generic<[MyAttribute(System.AttributeTargets.GenericParameter)] T> {}

        // C# does not support attributes on interface implementations, though .NET does.
        // class InterfaceImpl: [MyAttribute(0)] Interface {}

        class Members
        {
            [MyAttribute(System.AttributeTargets.Constructor)] Members() {}
            [MyAttribute(System.AttributeTargets.Field)] bool Field;
            [MyAttribute(System.AttributeTargets.Property)] bool Property { get; }
            [MyAttribute(System.AttributeTargets.Method)] void Method() {}
            [MyAttribute(System.AttributeTargets.Event)] event System.Action Event;
        }

        [return: MyAttribute(System.AttributeTargets.ReturnValue)] delegate bool Parameters(
            [MyAttribute(System.AttributeTargets.Parameter)] bool param1);
        """)
    }

    public struct MyAttributeAttribute: AttributeType {
        public var target: AttributeTargets

        public init(_ target: AttributeTargets) {
            self.target = target
        }

        public static var namespace: String? { nil }
        public static var name: String { "MyAttributeAttribute" }
        public static var validOn: AttributeTargets { .all }
        public static var allowMultiple: Bool { false }
        public static var inherited: Bool { true }

        public static func decode(_ attribute: Attribute) throws -> MyAttributeAttribute {
            let arguments = try attribute.arguments
            guard arguments.count == 1,
                case .constant(let constant) = arguments[0],
                case .int32(let value) = constant else { throw InvalidMetadataError.attributeArguments }
            return MyAttributeAttribute(AttributeTargets(rawValue: value))
        }
    }

    @Test(.enabled(if: false))
    func testAssembly() throws {
        fatalError("Not implemented")
    }

    @Test(.enabled(if: false))
    func testModule() throws {
        fatalError("Not implemented")
    }

    @Test func testTypeDefinitions() throws {
        func assertHasAttribute(typeName: String, expectedTarget: AttributeTargets) throws {
            let typeDefinition = try #require(try assembly.resolveTypeDefinition(fullName: typeName))
            let attribute = try #require(try typeDefinition.findAttribute(MyAttributeAttribute.self))
            #expect(attribute.target == expectedTarget)
        }

        try assertHasAttribute(typeName: "Delegate", expectedTarget: .delegate)
        try assertHasAttribute(typeName: "Enum", expectedTarget: .enum)
        try assertHasAttribute(typeName: "Interface", expectedTarget: .interface)
        try assertHasAttribute(typeName: "Struct", expectedTarget: .struct)
        try assertHasAttribute(typeName: "Class", expectedTarget: .class)
    }

    @Test func testGenericParam() throws {
        let typeDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Generic`1"))
        let genericParam = try #require(try typeDefinition.genericParams.first)
        let attribute = try #require(genericParam.findAttribute(MyAttributeAttribute.self))
        #expect(attribute.target == .genericParameter)
    }

    @Test func testMembers() throws {
        func assertHasAttribute(member: Member?, expectedTarget: AttributeTargets) throws {
            let member = try #require(member)
            let attribute = try #require(member.findAttribute(MyAttributeAttribute.self))
            #expect(attribute.target == expectedTarget)
        }

        let typeDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Members"))
        try assertHasAttribute(member: typeDefinition.findMethod(name: ".ctor"), expectedTarget: .constructor)
        try assertHasAttribute(member: typeDefinition.findField(name: "Field"), expectedTarget: .field)
        try assertHasAttribute(member: typeDefinition.findProperty(name: "Property"), expectedTarget: .property)
        try assertHasAttribute(member: typeDefinition.findMethod(name: "Method"), expectedTarget: .method)
        try assertHasAttribute(member: typeDefinition.findEvent(name: "Event"), expectedTarget: .event)
    }

    @Test func testParameters() throws {
        func assertHasAttribute(param: ParamBase?, expectedTarget: AttributeTargets) throws {
            let param = try #require(param)
            let attribute = try #require(param.findAttribute(MyAttributeAttribute.self))
            #expect(attribute.target == expectedTarget)
        }

        let delegateDefinition = try #require(try assembly.resolveTypeDefinition(fullName: "Parameters") as? DelegateDefinition)
        try assertHasAttribute(param: delegateDefinition.invokeMethod.returnParam, expectedTarget: .returnValue)
        try assertHasAttribute(param: delegateDefinition.invokeMethod.params.first, expectedTarget: .parameter)
    }
}