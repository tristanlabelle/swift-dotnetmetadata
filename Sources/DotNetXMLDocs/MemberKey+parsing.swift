extension MemberKey {
    public init(parsing str: String) throws {
        self = Self.parse(str)
    }

    struct InvalidFormatError: Error {}

    fileprivate static func parse(str: String) throws -> MemberKey {
        var remainder = Substring(str)
        guard let kindChar = remainder.popFirst(), tryConsume(&remainder, ":") else {
            throw InvalidFormatError()
        }

        let identifier = try consumeDottedIdentifier(&remainder)
        if kindChar == "N" {
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .namespace(name: String(identifier))
        }
        if kindChar == "T" {
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .type(fullName: String(identifier))
        }

        let memberDotIndex = identifier.lastIndex(of: ".")
        let typeFullName = String(str[...(memberDotIndex ?? str.startIndex)])
        let memberName = String(str[(memberDotIndex + 1 ?? str.startIndex)...])
        if kindChar == "F" {
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .field(typeFullName: typeFullName, name: memberName)
        }
        if kindChar == "E" {
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .event(typeFullName: typeFullName, name: memberName)
        }

        var params: [Param] = []
        if remainder.tryConsume("(") {
            while !tryConsume(&remainder, ")") {
                if !params.isEmpty && !tryConsume(&remainder, ",") { throw InvalidFormatError() }
                params.append(consumeParam(&remainder))
            }
        }

        if kindChar == "P" {
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .property(typeFullName: typeFullName, name: memberName, params: params)
        }

        // op_Implicit/op_Explicit
        let conversionTarget: Param?
        if remainder.tryConsume("~") {
            conversionTarget = consumeParam(&remainder)
        }
        else {
            conversionTarget = nil
        }

        if kindChar == "M" {
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .method(typeFullName: typeFullName, name: memberName, params: params, conversionTarget: param)
        }

        throw InvalidFormatError()
    }

    fileprivate static func consumeDottedIdentifier(_ str: inout Substring) throws -> Substring {
        let identifier = remainder.drop(while: { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "`" || $0 == "." })
        guard !identifier.isEmpty else { throw InvalidFormatError() }
        return identifier
    }

    fileprivate static func consumeParam(_ str: inout Substring) throws -> Param {
        return Param(type: .bound(String(try consumeDottedIdentifier(&str))))
    }

    fileprivate static func tryConsume(_ str: inout Substring, _ prefix: Character) -> Bool {
        guard str.first == prefix else { return false }
        str.dropFirst()
        return true
    }
}
