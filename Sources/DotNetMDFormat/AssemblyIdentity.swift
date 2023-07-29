// Identifies an assembly by its simple name, version, culture, and public key.
// This corresponds to the System.Reflection.AssemblyName class in .NET.
public struct AssemblyIdentity: Hashable, CustomStringConvertible {
    public enum PublicKey: Hashable {
        case full([UInt8]) // Full strong name key (.snk) file
        case token([UInt8]) // Last 8 bytes of SHA-1 of full key
    }

    public var name: String
    // Version should always be present in definitions, but is allowed to be null for references
    public var version: AssemblyVersion?
    public var culture: String?
    public var publicKey: PublicKey?

    public init(name: String, version: AssemblyVersion? = nil, culture: String? = nil, publicKey: PublicKey? = nil) {
        self.name = name
        self.version = version
        self.culture = culture
        self.publicKey = publicKey
    }

    public var description: String {
        // mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
        var result = name

        if let version = version {
            result += ", Version=\(version)"
        }

        if let culture = culture {
            result += ", Culture=\(culture)"
        }

        switch publicKey {
            case .full(_): fatalError("Not implemented: ")
            case let .token(value):
                result += ", PublicKeyToken=0x"
                for byte in value {
                    result += String(format: "%02x", byte)
                }
            case nil: break
        }

        return result
    }
}

extension AssemblyIdentity: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        guard !stringLiteral.contains(",") else {
            fatalError("Not implemented: Parsing AssemblyIdentity with more than simple names")
        }

        self.name = stringLiteral
    }
}

extension AssemblyIdentity {
    public init(fromRow row: TableRows.AssemblyRef, in moduleFile: ModuleFile) {
        name = moduleFile.resolve(row.name)
        version = row.version
        culture = row.culture.value == 0 ? nil : moduleFile.resolve(row.culture)
        if row.publicKeyOrToken.value == 0 {
            publicKey = nil
        }
        else {
            let publicKeyBytes = Array(moduleFile.resolve(row.publicKeyOrToken))
            publicKey = row.flags.contains(.publicKey) ? .full(publicKeyBytes) : .token(publicKeyBytes)
        }
    }
}