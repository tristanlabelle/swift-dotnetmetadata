import WinMD

/// WinMD files refer to mscorlib 255.255.255.255, which is not a real assembly,
/// but we still want to have definitions for fundamental types like System.Object,
/// System.ValueType, System.Int32, System.String, System.Enum, etc.
extension Assembly {
    final class MockMscorlibImpl: Impl {
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
                    impl: TypeDefinition.MockSystemTypeImpl(name: $0))
            }
        }

        public var name: String { "mscorlib" }
        public var version: AssemblyVersion { .all255 }
        public var types: [TypeDefinition] { systemTypes }
    }
}
