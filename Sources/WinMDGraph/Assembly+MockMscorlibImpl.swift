import WinMD

/// WinMD files refer to mscorlib 255.255.255.255, which is not a real assembly,
/// but we still want to have definitions for fundamental types like System.Object,
/// System.ValueType, System.Int32, System.String, System.Enum, etc.
extension Assembly {
    final class MockMscorlibImpl: Impl {
        private var systemTypes: [TypeDefinition] = []

        func initialize(owner: Assembly) {
            // System.Object and derived types
            let object = TypeDefinition(
                assembly: owner,
                impl: TypeDefinition.MockSystemTypeImpl(name: "Object", base: nil))
            systemTypes.append(object)
            systemTypes.append(contentsOf: [
                "Enum", "Delegate",
                "Type", "Attribute", "Exception", "String" ].map {
                    TypeDefinition(
                        assembly: owner,
                        impl: TypeDefinition.MockSystemTypeImpl(name: $0, base: object))
                })

            // System.ValueType and derived types
            let valueType = TypeDefinition(
                assembly: owner,
                impl: TypeDefinition.MockSystemTypeImpl(name: "ValueType", base: object))
            systemTypes.append(valueType)
            systemTypes.append(contentsOf: [
                "Void",
                "Boolean", "Char",
                "Int8", "UInt8", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64", 
                "IntPtr", "UIntPtr",
                "Single", "Double" ].map {
                    TypeDefinition(
                        assembly: owner,
                        impl: TypeDefinition.MockSystemTypeImpl(name: $0, base: valueType))
                })
        }

        public var name: String { "mscorlib" }
        public var version: AssemblyVersion { .all255 }
        public var culture: String { "" }
        public var types: [TypeDefinition] { systemTypes }
    }
}
