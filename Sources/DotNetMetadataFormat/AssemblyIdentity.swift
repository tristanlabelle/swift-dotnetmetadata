// Identifies an assembly by its simple name, version, culture, and public key.
// This corresponds to the System.Reflection.AssemblyName class in .NET.
public struct AssemblyIdentity: Hashable, CustomStringConvertible {
    public struct ParseError: Error {}

    public var name: String
    // Version should always be present in definitions, but is allowed to be null for references
    public var version: FourPartVersion?
    public var culture: String?
    public var publicKey: AssemblyPublicKey?

    public init(name: String, version: FourPartVersion? = nil, culture: String? = nil, publicKey: AssemblyPublicKey? = nil) {
        self.name = name
        self.version = version
        self.culture = culture
        self.publicKey = publicKey
    }

    public var description: String {
        // mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089
        var result = name

        if let version {
            result += ", Version=\(version)"
        }

        if let culture {
            result += ", Culture=\(culture)"
        }

        switch publicKey {
            case .full(let bytes):
                result += ", PublicKey="
                for byte in bytes {
                    result += String(format: "%02x", byte)
                }
            case .token(let bytes):
                result += ", PublicKeyToken="
                for byte in bytes {
                    result += String(format: "%02x", byte)
                }
            case nil:
                // The .NET implementation appends either of
                // PublicKey=null / PublicKeyToken=null
                break
        }

        return result
    }

    public static func parse(_ str: String) throws -> AssemblyIdentity {
        // System.Runtime, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a
        let segments = str.split(separator: try Regex(#"\s*,\s*"#))
        if segments.count == 1 { return .init(name: str) }

        let name = String(segments[0])
        var index = 1

        let version: FourPartVersion?
        if index < segments.count, let match = try segments[index].wholeMatch(of: Regex(#"Version=(\d+)\.(\d+)\.(\d+)\.(\d+)"#)) {
            version = FourPartVersion(
                major: UInt16(match[1].substring!)!,
                minor: UInt16(match[2].substring!)!,
                buildNumber: UInt16(match[3].substring!)!,
                revisionNumber: UInt16(match[4].substring!)!)
            index += 1
        }
        else {
            version = nil
        }

        let culture: String?
        if index < segments.count, let match = try segments[index].wholeMatch(of: Regex(#"Culture=([a-zA-Z-]+)"#)) {
            culture = String(match[1].substring!)
            index += 1
        }
        else {
            culture = nil
        }

        let publicKey: AssemblyPublicKey?
        if index < segments.count, let match = try segments[index].wholeMatch(of: Regex(#"PublicKey(Token)?=(null|[a-fA-F0-9]+)"#)) {
            let valueString = match[2].substring!
            if valueString == "null" {
                publicKey = nil
            }
            else {
                if valueString.count % 2 != 0 {
                    throw ParseError()
                }

                var valueRemainder = Substring(valueString)
                var bytes: [UInt8] = []
                while !valueRemainder.isEmpty {
                    bytes.append(UInt8(valueRemainder.prefix(2), radix: 16)!)
                    valueRemainder = valueRemainder.dropFirst(2)
                }

                let isToken = match[1].range != nil
                if isToken && bytes.count != 8 {
                    throw ParseError()
                }

                publicKey = isToken ? .token(bytes) : .full(bytes)
            }

            index += 1
        }
        else {
            publicKey = nil
        }

        guard index == segments.count else { throw ParseError() }

        return .init(name: name, version: version, culture: culture, publicKey: publicKey)
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