import DotNetMDFormat

extension TypeDefinition {
    final class MockSystemTypeImpl: Impl {
        public let kind: TypeDefinitionKind
        public let name: String
        public let base: BoundType?
        internal let metadataAttributes: TypeAttributes

        internal init(
            kind: TypeDefinitionKind,
            name: String,
            base: ClassDefinition?,
            metadataAttributes: TypeAttributes) {

            self.kind = kind
            self.name = name
            if let base {
                self.base = .init(base, genericArgs: [])
            } else {
                self.base = nil
            }
            self.metadataAttributes = metadataAttributes
        }

        func initialize(owner: TypeDefinition) {}

        public var namespace: String? { "System" }
        public var enclosingType: TypeDefinition? { nil }
        public var baseInterfaces: [BaseInterface] { [] }
        public var genericParams: [GenericTypeParam] { [] }
        public var fields: [Field]  { [] }
        public var methods: [Method] { [] }
        public var properties: [Property] { [] }
        public var events: [Event] { [] }
        public var attributes: [Attribute] { [] }
    }
}