import DotNetMetadata

// Attributes applying to (runtime)classes
extension FoundationAttributes {
    public static func getDualApiPartitionVersion(_ class: ClassDefinition) throws -> Version? {
        guard let attribute = try `class`.firstAttribute(namespace: namespace, name: "DualApiPartitionAttribute") else { return nil }
        let namedArguments = try attribute.namedArguments
        if namedArguments.count == 0 { return Version(major: 0, minor: 0) }
        guard namedArguments.count <= 1,
            case .field(let field) = namedArguments[0].target,
            field.name == "version",
            case .constant(let versionConstant) = namedArguments[0].value,
            case .uint32(let versionValue) = versionConstant else { throw InvalidMetadataError.attributeArguments }
        return Version(unpacking: versionValue)
    }

    public static func isDefaultInterface(_ baseInterface: BaseInterface) throws -> Bool {
        try baseInterface.hasAttribute(namespace: namespace, name: "DefaultAttribute")
    }

    public static func getDefaultInterface(_ class: ClassDefinition) throws -> BoundType? {
        try `class`.baseInterfaces.first { try isDefaultInterface($0) }?.interface
    }

    public static func getActivations(_ class: ClassDefinition) throws -> [Activation] {
        return try `class`.attributes.filter { try $0.type.namespace == namespace && $0.type.name == "ActivatableAttribute" }
            .map {
                let arguments = try $0.arguments
                guard arguments.count >= 1 else { throw InvalidMetadataError.attributeArguments }

                if case .type(let factoryDefinition) = arguments[0] {
                    guard let factory = factoryDefinition as? InterfaceDefinition else { throw InvalidMetadataError.attributeArguments }
                    return Activation(factory: factory, applicability: try toVersionApplicability(arguments[1...]))
                }
                else {
                    return Activation(applicability: try toVersionApplicability(arguments[...]))
                }
            }
    }

    public static func getStaticInterfaces(_ class: ClassDefinition) throws -> [StaticInterface] {
        return try `class`.attributes.filter { try $0.type.namespace == namespace && $0.type.name == "StaticAttribute" }
            .map {
                let arguments = try $0.arguments
                guard arguments.count >= 2 else { throw InvalidMetadataError.attributeArguments }
                guard case .type(let definition) = arguments[0],
                    let interface = definition as? InterfaceDefinition else { throw InvalidMetadataError.attributeArguments }
                return StaticInterface(interface: interface, applicability: try toVersionApplicability(arguments[1...]))
            }
    }

    public static func getCompositions(_ class: ClassDefinition) throws -> [Composition] {
        return try `class`.attributes.filter { try $0.type.namespace == namespace && $0.type.name == "ComposableAttribute" }
            .map {
                let arguments = try $0.arguments
                guard arguments.count >= 3 else { throw InvalidMetadataError.attributeArguments }

                guard case .type(let factoryDefinition) = arguments[0],
                    let factory = factoryDefinition as? InterfaceDefinition,
                    case .constant(let typeConstant) = arguments[1],
                    case .int32(let typeValue) = typeConstant,
                    let kind = Composition.Kind(rawValue: typeValue) else { throw InvalidMetadataError.attributeArguments }

                return Composition(factory: factory, kind: kind,
                    applicability: try toVersionApplicability(arguments[2...]))
            }
    }
}