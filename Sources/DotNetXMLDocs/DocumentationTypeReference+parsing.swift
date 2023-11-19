extension DocumentationTypeReference {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self(consuming: &remainder)
        guard remainder.isEmpty else { throw DocumentationFormatError() }
    }

    internal init(consuming str: inout Substring, ignoreMemberSuffix: Bool = false) throws {
        self = try Self.consume(&str, ignoreMemberSuffix: ignoreMemberSuffix)
    }

    internal static func consume(_ remainder: inout Substring, ignoreMemberSuffix: Bool = false) throws -> Self {
        let identifier = try consumeNamespaceAndName(&remainder, ignoreMemberSuffix: ignoreMemberSuffix)
        let genericity = try consumeGenericity(&remainder)

        return Self(
            namespace: identifier.namespace.map(String.init),
            nameWithoutGenericSuffix: String(identifier.name),
            genericity: genericity)
    }

    internal static func consumeNamespaceAndName(
            _ remainder: inout Substring,
            ignoreMemberSuffix: Bool = false) throws -> (namespace: Substring?, name: Substring) {
        let original = remainder
        var name = try consumeIdentifier(&remainder)
        var namespace: Substring? = nil
        while true {
            let preDot = remainder
            guard remainder.tryConsume(".") else { break }
            let newName: Substring
            if ignoreMemberSuffix {
                if let possibleName = try? consumeIdentifier(&remainder),
                    remainder.first == "." || remainder.first == "`" || remainder.first == "{" {
                    newName = possibleName
                }
                else {
                    remainder = preDot
                    break
                }
            }
            else {
                newName = try consumeIdentifier(&remainder)
            }

            namespace = original[..<preDot.startIndex]
            name = newName
        }

        return (namespace, name)
    }

    internal static func consumeGenericity(_ remainder: inout Substring) throws -> Genericity {
        // Parse generic arity such as `1
        let genericArity: Int
        if remainder.tryConsume("`") {
            let digits = remainder.consume(while: { $0.isNumber })
            guard let value = Int(digits), value > 0 else { throw DocumentationFormatError() }
            genericArity = value
        }
        else {
            genericArity = 0
        }

        // Parse bound generic args such as {System.String}
        let genericArgs: [DocumentationTypeNode]? = try {
            guard remainder.tryConsume("{") else { return nil }

            var genericArgs: [DocumentationTypeNode] = []
            while !remainder.tryConsume("}") {
                if !genericArgs.isEmpty && !remainder.tryConsume(",") { throw DocumentationFormatError() }
                genericArgs.append(try DocumentationTypeNode(consuming: &remainder))
            }

            return genericArgs
        }()

        if let genericArgs {
            guard genericArity == genericArgs.count else { throw DocumentationFormatError() }
            return .bound(genericArgs)
        }
        else {
            return genericArity == 0 ? .bound([]) : .unbound(arity: genericArity)
        }
    }
}
