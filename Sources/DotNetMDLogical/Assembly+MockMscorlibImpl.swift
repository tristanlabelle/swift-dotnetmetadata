import DotNetMDPhysical

/// DotNetMDPhysical files refer to mscorlib 255.255.255.255, which is not a real assembly,
/// but we still want to have definitions for fundamental types like System.Object,
/// System.ValueType, System.Int32, System.String, System.Enum, etc.
extension Assembly {
    final class MockMscorlibImpl: Impl {
        private var systemTypes: [TypeDefinition] = []

        func initialize(owner: Assembly) {
            // System.Object and derived types
            func makeType(kind: TypeDefinitionKind, name: String, base: TypeDefinition?) -> TypeDefinition {
                TypeDefinition.create(
                    assembly: owner,
                    impl: TypeDefinition.MockSystemTypeImpl(kind: kind, name: name, base: base))
            }

            let object = makeType(kind: .class, name: "Object", base: nil)
            systemTypes.append(object)
            systemTypes.append(contentsOf: [
                "Array", "Attribute", "Exception", "Type", "String" ].map {
                    makeType(kind: .class, name: $0, base: object)
                })

            let delegate = makeType(kind: .class, name: "Delegate", base: object)
            systemTypes.append(delegate)
            systemTypes.append(makeType(kind: .class, name: "MulticastDelegate", base: delegate))

            // System.ValueType and derived types
            let valueType = makeType(kind: .class, name: "ValueType", base: object)
            systemTypes.append(valueType)
            systemTypes.append(makeType(kind: .class, name: "Enum", base: valueType))
            systemTypes.append(contentsOf: [
                "Void",
                "Boolean", "Char",
                "SByte", "Byte", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64", 
                "IntPtr", "UIntPtr",
                "Single", "Double" ].map {
                    makeType(kind: .struct, name: $0, base: valueType)
                })
        }

        public var name: String { "mscorlib" }
        public var version: AssemblyVersion { .all255 }
        public var culture: String { "" }
        public var definedTypes: [TypeDefinition] { systemTypes }
    }
}
