import DotNetMetadataFormat

/// Represents a custom .NET attribute instance as applied to a type, member, or other metadata element.
public final class Attribute {
    public private(set) weak var assembly: Assembly!
    internal let tableRowIndex: TableRowIndex // In CustomAttribute table

    init(tableRowIndex: TableRowIndex, assembly: Assembly) {
        self.tableRowIndex = tableRowIndex
        self.assembly = assembly
    }

    internal var moduleFile: ModuleFile { assembly.moduleFile }
    private var tableRow: CustomAttributeTable.Row { moduleFile.customAttributeTable[tableRowIndex] }

    private var cachedConstructor: Constructor?
    public var constructor: Constructor { get throws {
        try cachedConstructor.lazyInit {
            try assembly.resolveCustomAttributeType(tableRow.type) as! Constructor
        }
    } }
    public var type: TypeDefinition { get throws { try constructor.definingType } }

    private var cachedSignature: CustomAttribSig?
    public var signature: CustomAttribSig { get throws {
        try cachedSignature.lazyInit {
            let constructor = try self.constructor
            let paramTypes = try constructor.params.map {
                try Self.toElemType($0.signature.type) ?? Self.toElemType($0.type)
            }
            return try CustomAttribSig(
                    blob: moduleFile.resolve(tableRow.value),
                    paramTypes: paramTypes,
                    memberTypeResolver: { kind, name, typeSig in
                if let elemType = try Self.toElemType(typeSig) { return elemType }
                let typeNode: TypeNode = try {
                    switch kind {
                        case .field: return try self.type.findField(name: name)!.type
                        case .property: return try self.type.findProperty(name: name)!.type
                    }
                }()
                return try Self.toElemType(typeNode)
            })
        }
    } }

    private var cachedArguments: [Value]?
    public var arguments: [Value] { get throws {
        try cachedArguments.lazyInit { 
            try signature.fixedArgs.map { try resolve($0) }
        }
    } }

    private var cachedNamedArguments: [NamedArgument]?
    public var namedArguments: [NamedArgument] { get throws {
        try cachedNamedArguments.lazyInit {
            try signature.namedArgs.map { try resolve($0) }
        }
    } }

    internal func breakReferenceCycles() {
        cachedConstructor = nil
        cachedArguments = nil
        cachedNamedArguments = nil
    }

    private func resolve(_ elem: CustomAttribSig.Elem) throws -> Value {
        switch elem {
            case .constant(let constant): return .constant(constant)

            case let .type(fullName, assemblyIdentity):
                let typeDefinition: TypeDefinition
                if let assemblyIdentity {
                    typeDefinition = try self.assembly.context.resolveType(
                        assembly: assemblyIdentity, assemblyFlags: nil,
                        name: TypeName(fullName: fullName))
                }
                else {
                    // TODO: Fallback to mscorlib
                    // §II.23.3: 
                    // > If the assembly name is omitted, the CLI looks first in the current assembly,
                    // > and then in the system library (mscorlib); in these two special cases,
                    // > it is permitted to omit the assembly-name, version, culture and public-key-token.
                    typeDefinition = try self.assembly.resolveTypeDefinition(fullName: fullName)!
                }
                return .type(definition: typeDefinition)

            case .array(let elems): return .array(try elems.map(resolve))
            case .boxed(_): fatalError("Not implemented: boxed custom attribute arguments")
        }
    }

    private func resolve(_ namedArg: CustomAttribSig.NamedArg) throws -> NamedArgument {
        let target: NamedArgument.Target
        switch namedArg.memberKind {
            case .field: target = .field(try type.findField(name: namedArg.name)!)
            case .property: target = .property(try type.findProperty(name: namedArg.name)!)
        }

        return NamedArgument(target: target, value: try resolve(namedArg.value))
    }

    // Most CustomAttribSig.ElemType values can be directly inferred from the TypeSig.
    private static func toElemType(_ typeSig: TypeSig) throws -> CustomAttribSig.ElemType? {
        switch typeSig {
            case .boolean: return .boolean
            case .char: return .char
            case .integer(let size, let signed): return .integer(size: size, signed: signed)
            case .real(let double): return .real(double: double)
            case .string: return .string
            case .array(of: let elemSig, shape: let shape):
                guard let elemType = try toElemType(elemSig) else { return nil }
                guard shape == ArrayShape.vector else {
                    fatalError("Not implemented: multidimensional arrays in custom attribute arguments")
                }
                return .array(of: elemType)
            case .szarray(customMods: _, of: let elemSig):
                guard let elemType = try toElemType(elemSig) else { return nil }
                return .array(of: elemType)
            default: return nil
        }
    }

    private static func toElemType(_ type: TypeNode) throws -> CustomAttribSig.ElemType {
        switch type {
            case .bound(let type) where type.genericArgs.isEmpty:
                return try toElemType(type.definition)
            case .array(of: let elemType):
                return .array(of: try toElemType(elemType))
            default:
                throw InvalidMetadataError.attributeArguments
        }
    }

    private static func toElemType(_ typeDefinition: TypeDefinition) throws -> CustomAttribSig.ElemType {
        if typeDefinition.fullName == "System.Type" { return .type }
        if let enumDefinition = typeDefinition as? EnumDefinition {
            return try toElemType(enumDefinition.backingField.signature.type)! // Should be a primitive type
        }
        throw InvalidMetadataError.attributeArguments
    }

    public struct NamedArgument: Hashable {
        public var target: Target
        public var value: Value

        public enum Target: Hashable {
            case property(Property)
            case field(Field)
        }
    }

    public enum Value: Hashable {
        case constant(Constant)
        case type(definition: TypeDefinition)
        case array([Value])
    }
}