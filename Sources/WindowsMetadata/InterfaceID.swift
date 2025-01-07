import DotNetMetadata
import struct Foundation.UUID

public func getInterfaceID(_ typeDefinition: TypeDefinition, genericArgs: [TypeNode]? = nil) throws -> UUID {
    guard typeDefinition is InterfaceDefinition || typeDefinition is DelegateDefinition else {
        throw UnexpectedTypeError(typeDefinition.fullName, context: #function, reason: "Only interfaces and delegates have interface IDs")
    }

    /// Generic interfaces/delegates have a GUID computed based on the generic arguments.
    if let genericArgs, genericArgs.count > 0 {
        let signature = try WinRTTypeSignature(typeDefinition.bindType(genericArgs: genericArgs))
        return signature.parameterizedID
    }
    /// Non-generic interfaces/delegates defined in winmd files specify their GUID via Windows.Foundation.Metadata.GuidAttribute.
    else if let attribute = try typeDefinition.findAttribute(WindowsMetadata.GuidAttribute.self) {
        return attribute.value
    }
    else {
        throw WinMDError.missingAttribute
    }
}

public func getInterfaceID(_ type: BoundType) throws -> UUID {
    try getInterfaceID(type.definition, genericArgs: type.genericArgs)
}