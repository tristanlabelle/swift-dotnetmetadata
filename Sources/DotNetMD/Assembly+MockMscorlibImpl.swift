import DotNetMDFormat

/// DotNetMDFormat files refer to mscorlib 255.255.255.255, which is not a real assembly,
/// but we still want to have definitions for fundamental types like System.Object,
/// System.ValueType, System.Int32, System.String, System.Enum, etc.
extension Assembly {
    final class MockMscorlibImpl: Impl {
        private var systemTypes: [TypeDefinition] = []

        func initialize(owner: Assembly) {
            func makeClass(name: String, base: ClassDefinition?, abstract: Bool = false, sealed: Bool = false) -> ClassDefinition {
                var metadataAttributes: TypeAttributes = [.public, .serializable]
                if abstract { metadataAttributes.insert(.abstract) }
                if sealed { metadataAttributes.insert(.sealed) }
                return TypeDefinition.create(
                    assembly: owner,
                    impl: TypeDefinition.MockSystemTypeImpl(
                        kind: .class,
                        name: name,
                        base: base,
                        metadataAttributes: metadataAttributes)) as! ClassDefinition
            }

            let object = makeClass(name: "Object", base: nil)
            systemTypes.append(object)
            systemTypes.append(makeClass(name: "Array", base: object, abstract: true))
            systemTypes.append(makeClass(name: "Attribute", base: object, abstract: true))
            systemTypes.append(makeClass(name: "Exception", base: object))
            systemTypes.append(makeClass(name: "Type", base: object, abstract: true))
            systemTypes.append(makeClass(name: "String", base: object, sealed: true))

            let delegate = makeClass(name: "Delegate", base: object, abstract: true)
            systemTypes.append(delegate)
            systemTypes.append(makeClass(name: "MulticastDelegate", base: delegate, abstract: true))

            // System.ValueType and derived types
            let valueType = makeClass(name: "ValueType", base: object, abstract: true)
            systemTypes.append(valueType)
            systemTypes.append(makeClass(name: "Enum", base: valueType, abstract: true))
            systemTypes.append(contentsOf: [
                "Void", "TypedReference", "Guid",
                "Boolean", "Char",
                "SByte", "Byte", "Int16", "UInt16", "Int32", "UInt32", "Int64", "UInt64", 
                "IntPtr", "UIntPtr",
                "Single", "Double" ].map {
                    TypeDefinition.create(
                        assembly: owner,
                        impl: TypeDefinition.MockSystemTypeImpl(
                            kind: .struct,
                            name: $0,
                            base: valueType,
                            metadataAttributes: [.public, .serializable, .sealed]))
                })
        }

        public var name: String { "mscorlib" }
        public var version: AssemblyVersion { .all255 }
        public var culture: String { "" }
        public var definedTypes: [TypeDefinition] { systemTypes }
    }
}
