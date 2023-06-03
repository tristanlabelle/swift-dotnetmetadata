import WinMD

extension TypeDefinition {
    final class MockSystemTypeImpl: Impl {
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