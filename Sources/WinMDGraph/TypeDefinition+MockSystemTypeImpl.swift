import WinMD

extension TypeDefinition {
    final class MockSystemTypeImpl: Impl {
        public let name: String
        public let base: Type?

        internal init(name: String, base: TypeDefinition?) {
            self.name = name
            self.base = base?.bindNonGeneric()
        }

        func initialize(owner: TypeDefinition) {}

        public var namespace: String { "System" }

        // FIXME: We'll need a few more attributes than that
        internal var metadataFlags: WinMD.TypeAttributes { WinMD.TypeAttributes.public }

        public var baseInterfaces: [BaseInterface] { [] }
        public var genericParams: [GenericTypeParam] { [] }
        public var fields: [Field]  { [] }
        public var methods: [Method] { [] }
        public var properties: [Property] { [] }
        public var events: [Event] { [] }
    }
}