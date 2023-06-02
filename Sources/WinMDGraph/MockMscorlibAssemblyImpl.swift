import WinMD

/// WinMD files refer to mscorlib 255.255.255.255, which is not a real assembly,
/// but we still want to have definitions for fundamental types like System.Object,
/// System.ValueType, System.Int32, System.String, System.Enum, etc.
final class MockMscorlibAssemblyImpl: AssemblyImpl {
    private var systemTypes: [TypeDefinition] = []

    func initialize(parent: Assembly) {
        systemTypes = [
            "Void", "Object", "ValueType", "Enum", "Delegate",
            "Type", "Exception", "String",
            "Boolean", "Char",
            "Int8", "UInt8", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64",
            "Single", "Double"
        ].map {
            TypeDefinition(
                assembly: parent,
                impl: SystemTypeDefinitionImpl(name: $0))
        }
    }

    public var name: String { "mscorlib" }
    public var types: [TypeDefinition] { systemTypes }
}

extension MockMscorlibAssemblyImpl {
    final class SystemTypeDefinitionImpl: TypeDefinitionImpl {
        public let name: String

        internal init(name: String) {
            self.name = name
        }

        func initialize(parent: TypeDefinition) {}

        public var namespace: String { "System" }

        // FIXME: We'll need a few more attributes than that
        internal var metadataFlags: WinMD.TypeAttributes { WinMD.TypeAttributes.public }

        public var genericParams: [GenericParam] { [] }
        public var base: TypeDefinition? { nil } // FIXME: Might need to reflect Enum : ValueType : Object here
        public var fields: [Field]  { [] }
        public var methods: [Method] { [] }
        public var properties: [Property] { [] }
        public var events: [Event] { [] }
    }
}