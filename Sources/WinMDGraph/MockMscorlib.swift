import WinMD

/// WinMD files refer to mscorlib 255.255.255.255, which is not a real assembly,
/// but we still want to have definitions for fundamental types like System.Object,
/// System.ValueType, System.Int32, System.String, System.Enum, etc.
final class MockMscorlib: Assembly {
    private var systemTypes: [TypeDefinition] = []

    override init() {
        super.init()
        systemTypes = [
            "Void", "Object", "ValueType", "Enum", "Delegate",
            "Boolean", "Char",
            "Int8", "UInt8", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64",
            "Single", "Double"
        ].map { SystemTypeDefinition(assembly: self, name: $0) as TypeDefinition }
    }

    public override var name: String { "mscorlib" }
    public override var types: [TypeDefinition] { systemTypes }
}

extension MockMscorlib {
    final class SystemTypeDefinition: TypeDefinition {
        private unowned let _assembly: Assembly
        private let _name: String

        internal init(assembly: MockMscorlib, name: String) {
            self._assembly = assembly
            self._name = name
        }
        
        public override var assembly: Assembly { _assembly }
        public override var name: String { _name }
        public override var namespace: String { "System" }

        // FIXME: We'll need a few more attributes than that
        internal override var metadataFlags: WinMD.TypeAttributes { WinMD.TypeAttributes.public }

        public override var genericParams: [GenericParam] { [] }
        public override var base: TypeDefinition? { nil } // FIXME: Might need to reflect Enum : ValueType : Object here
        public override var fields: [Field]  { [] }
        public override var methods: [Method] { [] }
        public override var properties: [Property] { [] }
        public override var events: [Event] { [] }
    }
}