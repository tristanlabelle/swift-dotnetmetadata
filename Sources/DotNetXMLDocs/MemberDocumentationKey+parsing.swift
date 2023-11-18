extension MemberDocumentationKey {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self.consume(&remainder)
        guard remainder.isEmpty else { throw DocumentationFormatError() }
    }

    fileprivate static func consume(_ remainder: inout Substring) throws -> Self {
        guard let kindChar = remainder.popFirst(), remainder.tryConsume(":") else {
            throw DocumentationFormatError()
        }

        if kindChar == "N" {
            let originalRemainder = remainder
            while true {
                _ = try consumeIdentifier(&remainder)
                guard remainder.tryConsume(".") else { break }
            }

            return .namespace(name: String(originalRemainder[..<remainder.startIndex]))
        }
        if kindChar == "T" {
            return .type(try DocumentationTypeReference(consuming: &remainder))
        }

        let declaringType = try DocumentationTypeReference(consuming: &remainder, ignoreMemberSuffix: true)

        // These should be a type name followed by a member name
        guard remainder.tryConsume(".") else { throw DocumentationFormatError() }
        let memberName = String(try consumeIdentifier(&remainder, allowConstructor: kindChar == "M"))

        if kindChar == "F" {
            guard remainder.isEmpty else { throw DocumentationFormatError() }
            return .field(declaringType: declaringType, name: memberName)
        }
        if kindChar == "E" {
            guard remainder.isEmpty else { throw DocumentationFormatError() }
            return .event(declaringType: declaringType, name: memberName)
        }

        var params: [Param] = []
        if remainder.tryConsume("(") {
            while !remainder.tryConsume(")") {
                if !params.isEmpty && !remainder.tryConsume(",") { throw DocumentationFormatError() }
                params.append(try Param(consuming: &remainder))
            }
        }

        if kindChar == "P" {
            guard remainder.isEmpty else { throw DocumentationFormatError() }
            return .property(declaringType: declaringType, name: memberName, params: params)
        }

        // op_Implicit/op_Explicit
        let conversionTarget: Param?
        if remainder.tryConsume("~") {
            conversionTarget = try Param(consuming: &remainder)
        }
        else {
            conversionTarget = nil
        }

        if kindChar == "M" {
            guard remainder.isEmpty else { throw DocumentationFormatError() }
            return .method(declaringType: declaringType, name: memberName, params: params, conversionTarget: conversionTarget)
        }

        throw DocumentationFormatError()
    }
}

extension MemberDocumentationKey.Param {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self(consuming: &remainder)
        guard remainder.isEmpty else { throw DocumentationFormatError() }
    }

    fileprivate init(consuming str: inout Substring) throws {
        self = try Self.consume(&str)
    }

    fileprivate static func consume(_ remainder: inout Substring) throws -> Self {
        let type = try DocumentationTypeNode(consuming: &remainder)
        let isByRef = remainder.tryConsume("@")
        if remainder.tryConsume("!") {
            // TODO: CustomMod support
            throw DocumentationFormatError()
        }

        return Self(type: type, isByRef: isByRef)
    }
}
