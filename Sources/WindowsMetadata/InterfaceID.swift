import DotNetMetadata
import struct Foundation.UUID

public func getInterfaceID(_ typeDefinition: TypeDefinition, genericArgs: [TypeNode]? = nil) throws -> UUID {
    guard typeDefinition is InterfaceDefinition || typeDefinition is DelegateDefinition else { throw WinMDError.unexpectedType }
    if let genericArgs = genericArgs, genericArgs.count > 0 {
        return try getParameterizedInterfaceID(typeDefinition.bindType(genericArgs: genericArgs))
    }
    else {
        guard let guid = try typeDefinition.findAttribute(GuidAttribute.self) else { throw WinMDError.missingAttribute }
        return guid
    }
}

public func getInterfaceID(_ type: BoundType) throws -> UUID {
    try getInterfaceID(type.definition, genericArgs: type.genericArgs)
}

// https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system#guid-generation-for-parameterized-types
fileprivate let parameterizedInterfaceGuidBytes: [UInt8] = [
    0x11, 0xf4, 0x7a, 0xd5,
    0x7b, 0x73,
    0x42, 0xc0,
    0xab, 0xae, 0x87, 0x8b, 0x1e, 0x16, 0xad, 0xee
];

public func getParameterizedInterfaceID(_ type: BoundType) throws -> UUID {
    var signature: String = ""
    try appendSignature(type, to: &signature)

    var sha1 = SHA1()
    sha1.process(parameterizedInterfaceGuidBytes)
    sha1.process(Array(signature.utf8))
    let hash = sha1.finalize()
    return UUID(uuid: (
        hash[0], hash[1], hash[2], hash[3],
        hash[4], hash[5],
        (hash[6] & 0x0F) | 0x50, hash[7],
        (hash[8] & 0x3F) | 0x80, hash[9],
        hash[10], hash[11], hash[12], hash[13], hash[14], hash[15]))
}

fileprivate func appendGuid(_ guid: UUID, to signature: inout String) {
    signature.append("{")
    signature.append(guid.uuidString.lowercased())
    signature.append("}")
}

fileprivate func appendSignature(_ type: BoundType, to signature: inout String) throws {
    if type.genericArgs.count > 0 {
        signature.append("pinterface(")
        appendGuid(try type.definition.findAttribute(GuidAttribute.self)!, to: &signature)
        signature.append(";")
        for (index, arg) in type.genericArgs.enumerated() {
            if index > 0 { signature.append(";") }
            guard case .bound(let arg) = arg else { throw WinMDError.unexpectedType }
            try appendSignature(arg, to: &signature)
        }
        signature.append(")")
        return
    }

    let typeDefinition = type.definition
    if typeDefinition.namespace == "System" {
        switch typeDefinition.name {
            case "Boolean": signature.append("b1")
            case "Byte": signature.append("u1")
            case "SByte": signature.append("i1")
            case "Int16": signature.append("i2")
            case "UInt16": signature.append("u2")
            case "Int32": signature.append("i4")
            case "UInt32": signature.append("u4")
            case "Int64": signature.append("i8")
            case "UInt64": signature.append("u8")
            case "Single": signature.append("f4")
            case "Double": signature.append("f8")
            case "Char": signature.append("c2")
            case "String": signature.append("string")
            case "Guid": signature.append("g16")
            case "Object": signature.append("cinterface(IInspectable)")
            default: throw WinMDError.unexpectedType
        }

        return
    }

    switch typeDefinition {
        case let structDefinition as StructDefinition:
            signature.append("struct(")
            signature.append(structDefinition.fullName)
            signature.append(";")
            for (index, field) in structDefinition.fields.enumerated() {
                guard field.isInstance else { continue }
                if index > 0 { signature.append(";") }
                guard case .bound(let fieldType) = try field.type else { throw WinMDError.unexpectedType }
                try appendSignature(fieldType, to: &signature)
            }
            signature.append(")")
        case let enumDefinition as EnumDefinition:
            signature.append("enum(")
            signature.append(enumDefinition.fullName)
            signature.append(";")
            try appendSignature(enumDefinition.underlyingType.bindType(), to: &signature)
            signature.append(")")
        case let delegateDefinition as DelegateDefinition:
            signature.append("delegate(")
            appendGuid(try delegateDefinition.findAttribute(GuidAttribute.self)!, to: &signature)
            signature.append(")")
        case let interfaceDefinition as InterfaceDefinition:
            appendGuid(try interfaceDefinition.findAttribute(GuidAttribute.self)!, to: &signature)
        case let classDefinition as ClassDefinition:
            signature.append("rc(")
            signature.append(classDefinition.fullName)
            signature.append(";")
            try appendSignature(DefaultAttribute.getDefaultInterface(classDefinition)!.asBoundType, to: &signature)
            signature.append(")")
        default:
            fatalError("Unexpected type definition: \(typeDefinition)")
    }
}