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

        let identifier = try consumeDottedIdentifier(&remainder)
        if kindChar == "N" {
            guard remainder.isEmpty else { throw DocumentationFormatError() }
            return .namespace(name: String(identifier))
        }
        if kindChar == "T" {
            guard remainder.isEmpty else { throw DocumentationFormatError() }
            return .type(fullName: String(identifier))
        }

        // These should be a type name followed by a member name
        guard let memberDotIndex = identifier.lastIndex(of: "."),
            memberDotIndex != identifier.startIndex,
            identifier.index(after: memberDotIndex) != identifier.endIndex
            else { throw DocumentationFormatError() }
        let declaringType = String(identifier[..<memberDotIndex])
        let memberName = String(identifier[identifier.index(after: memberDotIndex)...])

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
        let type = try MemberDocumentationKey.ParamType(consuming: &remainder)
        let isByRef = remainder.tryConsume("@")
        if remainder.tryConsume("!") {
            // TODO: CustomMod support
            throw DocumentationFormatError()
        }

        return Self(type: type, isByRef: isByRef)
    }
}

extension MemberDocumentationKey.ParamType {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self(consuming: &remainder)
        guard remainder.isEmpty else { throw DocumentationFormatError() }
    }

    fileprivate init(consuming str: inout Substring) throws {
        self = try Self.consume(&str)
    }

    fileprivate static func consume(_ remainder: inout Substring) throws -> Self {
        var type: MemberDocumentationKey.ParamType
        if remainder.tryConsume("`") {
            let kind = remainder.tryConsume("`") ? MemberDocumentationKey.GenericArgKind.method : .type
            let digits = remainder.consume(while: { $0.isNumber })
            guard let index = Int(digits) else { throw DocumentationFormatError() }
            type = .genericArg(index: index, kind: kind)
        }
        else {
            let typeIdentifier = try consumeDottedIdentifier(&remainder)
            var genericArgs: [MemberDocumentationKey.ParamType] = []
            if remainder.tryConsume("{") {
                while !remainder.tryConsume("}") {
                    if !genericArgs.isEmpty && !remainder.tryConsume(",") { throw DocumentationFormatError() }
                    genericArgs.append(try MemberDocumentationKey.ParamType(consuming: &remainder))
                }
            }

            type = .bound(fullName: String(typeIdentifier), genericArgs: genericArgs)
        }

        while true {
            if remainder.tryConsume("[") {
                guard remainder.tryConsume("]") else { throw DocumentationFormatError() }
                type = .array(of: type)
            }
            else if remainder.tryConsume("*") {
                type = .pointer(to: type)
            }
            else {
                break
            }
        }

        return type
    }
}

fileprivate func consumeDottedIdentifier(_ remainder: inout Substring) throws -> Substring {
    let identifier = remainder.consume(while: { $0.isLetter || $0.isNumber || $0 == "_" || $0 == "`" || $0 == "." || $0 == "#" })
    guard !identifier.isEmpty else { throw DocumentationFormatError() }
    return identifier
}

extension Substring {
    fileprivate mutating func consume(while predicate: (Character) -> Bool) -> Substring {
        var index = startIndex
        while index < endIndex && predicate(self[index]) {
            index = self.index(after: index)
        }

        let result = self[..<index]
        self = self[index...]
        return result
    }

    fileprivate mutating func tryConsume(_ prefix: Character) -> Bool {
        guard self.first == prefix else { return false }
        self = self.dropFirst()
        return true
    }
}