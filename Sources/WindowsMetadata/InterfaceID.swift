import DotNetMetadata
import struct Foundation.UUID

public func getInterfaceID(_ typeDefinition: TypeDefinition, genericArgs: [TypeNode]? = nil) throws -> UUID {
    guard typeDefinition is InterfaceDefinition || typeDefinition is DelegateDefinition else {
        throw UnexpectedTypeError(typeDefinition.fullName, context: #function, reason: "Only interfaces and delegates have interface IDs")
    }
    if let genericArgs = genericArgs, genericArgs.count > 0 {
        let signature = try WinRTTypeSignature(typeDefinition.bindType(genericArgs: genericArgs))
        return signature.parameterizedID
    }
    else {
        guard let guid = try typeDefinition.findAttribute(GuidAttribute.self) else { throw WinMDError.missingAttribute }
        return guid
    }
}

public func getInterfaceID(_ type: BoundType) throws -> UUID {
    try getInterfaceID(type.definition, genericArgs: type.genericArgs)
}