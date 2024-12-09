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
    /// We consider System.Runtime.InteropServices.WindowsRuntime.IActivationFactory to be a WinRT interface,
    /// but since it's defined in mscorlib, it uses System.Runtime.InteropServices.GuidAttribute instead.
    else if typeDefinition.namespace == "System.Runtime.InteropServices.WindowsRuntime",
            typeDefinition.name == "IActivationFactory",
            let attribute = try typeDefinition.findAttribute(DotNetMetadata.GuidAttribute.self) {
        guard let guid = UUID(uuidString: attribute.value) else { throw InvalidMetadataError.attributeArguments }
        return guid
    }
    else {
        throw WinMDError.missingAttribute
    }
}

public func getInterfaceID(_ type: BoundType) throws -> UUID {
    try getInterfaceID(type.definition, genericArgs: type.genericArgs)
}