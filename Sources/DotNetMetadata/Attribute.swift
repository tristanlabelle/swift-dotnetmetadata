import DotNetMetadataFormat

public final class Attribute {
    public unowned let assembly: Assembly
    internal let tableRowIndex: CustomAttributeTable.RowIndex

    init(tableRowIndex: CustomAttributeTable.RowIndex, assembly: Assembly) {
        self.tableRowIndex = tableRowIndex
        self.assembly = assembly
    }

    internal var moduleFile: ModuleFile { assembly.moduleFile }
    private var tableRow: CustomAttributeTable.Row { moduleFile.customAttributeTable[tableRowIndex] }

    private lazy var _constructor = Result {
        try assembly.resolve(tableRow.type) as! Constructor
    }
    public var constructor: Constructor { get throws { try _constructor.get() } }
    public var type: TypeDefinition { get throws { try constructor.definingType } }

    private lazy var _signature = Result {
        let constructor = try self.constructor
        let paramTypes = try constructor.params.map {
            try Self.toElemType($0.signature.type) ?? Self.toElemType($0.type)
        }
        return try CustomAttribSig(
                blob: moduleFile.resolve(tableRow.value),
                paramTypes: paramTypes,
                memberTypeResolver: { kind, name, typeSig in
            if let elemType = try Self.toElemType(typeSig) { return elemType }
            let typeNode = switch kind {
                case .field: try self.type.findField(name: name)!.type
                case .property: try self.type.findProperty(name: name)!.type
            }
            return try Self.toElemType(typeNode)
        })
    }
    public var signature: CustomAttribSig { get throws { try _signature.get() } }

    private lazy var _arguments = Result {
        try signature.fixedArgs.map { try resolve($0) }
    }
    public var arguments: [Value] { get throws { try _arguments.get() } }

    private lazy var _namedArguments = Result {
        try signature.namedArgs.map { try resolve($0) }
    }
    public var namedArguments: [NamedArgument] { get throws { try _namedArguments.get() } }

    private func resolve(_ elem: CustomAttribSig.Elem) throws -> Value {
        switch elem {
            case .constant(let constant): return .constant(constant)

            case let .type(fullName, assemblyIdentity):
                let assembly: Assembly
                if let assemblyIdentity {
                    assembly = try self.assembly.context.load(identity: assemblyIdentity)
                }
                else {
                    // TODO: Fallback to mscorlib
                    // §II.23.3: 
                    // > If the assembly name is omitted, the CLI looks first in the current assembly,
                    // > and then in the system library (mscorlib); in these two special cases,
                    // > it is permitted to omit the assembly-name, version, culture and public-key-token.
                    assembly = self.assembly
                }
                return .type(definition: assembly.findTypeDefinition(fullName: fullName)!)

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
            case .szarray(customMods: _, of: let elemType):
                guard let elemType = try toElemType(elemType) else { return nil }
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