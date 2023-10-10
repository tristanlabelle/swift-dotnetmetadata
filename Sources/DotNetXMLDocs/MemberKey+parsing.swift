extension MemberKey {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self.consume(&remainder)
        guard remainder.isEmpty else { throw InvalidFormatError() }
    }

    fileprivate static func consume(_ remainder: inout Substring) throws -> Self {
        guard let kindChar = remainder.popFirst(), remainder.tryConsume(":") else {
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

        // These should be a type name followed by a member name
        guard let memberDotIndex = identifier.lastIndex(of: "."),
            memberDotIndex != identifier.startIndex,
            identifier.index(after: memberDotIndex) != identifier.endIndex
            else { throw InvalidFormatError() }
        let typeFullName = String(identifier[..<memberDotIndex])
        let memberName = String(identifier[identifier.index(after: memberDotIndex)...])

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
            while !remainder.tryConsume(")") {
                if !params.isEmpty && !remainder.tryConsume(",") { throw InvalidFormatError() }
                params.append(try Param(consuming: &remainder))
            }
        }

        if kindChar == "P" {
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .property(typeFullName: typeFullName, name: memberName, params: params)
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
            guard remainder.isEmpty else { throw InvalidFormatError() }
            return .method(typeFullName: typeFullName, name: memberName, params: params, conversionTarget: conversionTarget)
        }

        throw InvalidFormatError()
    }
}

extension MemberKey.Param {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self(consuming: &remainder)
        guard remainder.isEmpty else { throw InvalidFormatError() }
    }

    fileprivate init(consuming str: inout Substring) throws {
        self = try Self.consume(&str)
    }

    fileprivate static func consume(_ remainder: inout Substring) throws -> Self {
        let type = try MemberKey.ParamType(consuming: &remainder)
        let isByRef = remainder.tryConsume("@")
        if remainder.tryConsume("!") {
            // TODO: CustomMod support
            throw InvalidFormatError()
        }

        return Self(type: type, isByRef: isByRef)
    }
}

extension MemberKey.ParamType {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self(consuming: &remainder)
        guard remainder.isEmpty else { throw InvalidFormatError() }
    }

    fileprivate init(consuming str: inout Substring) throws {
        self = try Self.consume(&str)
    }

    fileprivate static func consume(_ remainder: inout Substring) throws -> Self {
        var type: MemberKey.ParamType
        if remainder.tryConsume("`") {
            let kind = remainder.tryConsume("`") ? MemberKey.GenericArgKind.method : .type
            let digits = remainder.consume(while: { $0.isNumber })
            guard let index = Int(digits) else { throw InvalidFormatError() }
            type = .genericArg(index: index, kind: kind)
        }
        else {
            let typeIdentifier = try consumeDottedIdentifier(&remainder)
            var genericArgs: [MemberKey.ParamType] = []
            if remainder.tryConsume("{") {
                while !remainder.tryConsume("}") {
                    if !genericArgs.isEmpty && !remainder.tryConsume(",") { throw InvalidFormatError() }
                    genericArgs.append(try MemberKey.ParamType(consuming: &remainder))
                }
            }

            type = .bound(fullName: String(typeIdentifier), genericArgs: genericArgs)
        }

        while true {
            if remainder.tryConsume("[") {
                guard remainder.tryConsume("]") else { throw InvalidFormatError() }
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
    guard !identifier.isEmpty else { throw InvalidFormatError() }
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