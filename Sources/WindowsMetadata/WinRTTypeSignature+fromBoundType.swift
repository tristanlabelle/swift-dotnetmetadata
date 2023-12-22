import DotNetMetadata

extension WinRTTypeSignature {
    public init(_ type: BoundType) throws {
        self = try WinRTTypeSignature.fromBoundType(type)
    }

    private static func fromBoundType(_ type: BoundType) throws -> WinRTTypeSignature {
        if type.genericArgs.count > 0 {
            let id = try type.definition.findAttribute(GuidAttribute.self)!
            let args = try type.genericArgs.map {
                guard case .bound(let arg) = $0 else {
                    throw UnexpectedTypeError($0.description, context: "WinRT generic argument", reason: "Not a bound type")
                }
                return try fromBoundType(arg)
            }
            return type.definition is DelegateDefinition
                ? .delegate(id: id, args: args)
                : .interface(id: id, args: args)
        }

        if type.definition.namespace == "System" {
            switch type.definition.name {
                case "Boolean": return .baseType(.boolean)
                case "Byte": return .baseType(.uint8)
                case "Int16": return .baseType(.int16)
                case "UInt16": return .baseType(.uint16)
                case "Int32": return .baseType(.int32)
                case "UInt32": return .baseType(.uint32)
                case "Int64": return .baseType(.int64)
                case "UInt64": return .baseType(.uint64)
                case "Single": return .baseType(.single)
                case "Double": return .baseType(.double)
                case "Char": return .baseType(.char16)
                case "String": return .baseType(.string)
                case "Guid": return .baseType(.guid)
                case "Object": return .comInterface
                default: throw UnexpectedTypeError(type.definition.fullName, reason: "Not a well-known WinRT System type")
            }
        }

        switch type.definition {
            case is StructDefinition:
                let fields = try type.definition.fields.map {
                    let type = try $0.type
                    guard case .bound(let arg) = type else {
                        throw UnexpectedTypeError(type.description, context: "WinRT field", reason: "Not a bound type")
                    }
                    return try fromBoundType(arg)
                }
                return .struct(name: type.definition.fullName, fields: fields)

            case is EnumDefinition:
                return .enum(name: type.definition.fullName, flags: try type.definition.hasAttribute(FlagsAttribute.self))

            case is InterfaceDefinition:
                let id = try type.definition.findAttribute(GuidAttribute.self)!
                return .interface(id: id)

            case is DelegateDefinition:
                let id = try type.definition.findAttribute(GuidAttribute.self)!
                return .delegate(id: id)

            case let classDefinition as ClassDefinition:
                let defaultInterface = try DefaultAttribute.getDefaultInterface(classDefinition)!
                return .runtimeClass(name: classDefinition.fullName, defaultInterface: try fromBoundType(defaultInterface.asBoundType))

            default:
                fatalError("Unexpected type definition: \(type.definition)")
        }
    }
}