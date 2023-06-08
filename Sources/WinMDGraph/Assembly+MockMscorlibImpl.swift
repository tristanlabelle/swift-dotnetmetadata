import WinMD

/// WinMD files refer to mscorlib 255.255.255.255, which is not a real assembly,
/// but we still want to have definitions for fundamental types like System.Object,
/// System.ValueType, System.Int32, System.String, System.Enum, etc.
extension Assembly {
    final class MockMscorlibImpl: Impl {
        private var systemTypes: [TypeDefinition] = []

        func initialize(owner: Assembly) {
            // System.Object and derived types
            func makeType(name: String, base: TypeDefinition?) -> TypeDefinition {
                TypeDefinition(
                    assembly: owner,
                    impl: TypeDefinition.MockSystemTypeImpl(name: name, base: base))
            }

            let object = makeType(name: "Object", base: nil)
            systemTypes.append(object)
            systemTypes.append(contentsOf: [
                "Array", "Attribute", "Exception", "Type", "String" ].map {
                    makeType(name: $0, base: object)
                })

            let delegate = makeType(name: "Delegate", base: object)
            systemTypes.append(delegate)
            systemTypes.append(makeType(name: "MulticastDelegate", base: delegate))

            // System.ValueType and derived types
            let valueType = makeType(name: "ValueType", base: object)
            systemTypes.append(valueType)
            systemTypes.append(contentsOf: [
                "Void", "Enum",
                "Boolean", "Char",
                "SByte", "Byte", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64", 
                "IntPtr", "UIntPtr",
                "Single", "Double" ].map {
                    makeType(name: $0, base: valueType)
                })

            systemTypes.append(makeType(name: "IDisposable", base: nil)) // TODO: Make into an interface
        }

        public var name: String { "mscorlib" }
        public var version: AssemblyVersion { .all255 }
        public var culture: String { "" }
        public var types: [TypeDefinition] { systemTypes }
    }
}
