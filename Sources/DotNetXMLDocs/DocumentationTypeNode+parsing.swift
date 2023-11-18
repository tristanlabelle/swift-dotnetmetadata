
extension DocumentationTypeNode {
    public init(parsing str: String) throws {
        var remainder = Substring(str)
        self = try Self(consuming: &remainder)
        guard remainder.isEmpty else { throw DocumentationFormatError() }
    }

    internal init(consuming str: inout Substring) throws {
        self = try Self.consume(&str)
    }

    internal static func consume(_ remainder: inout Substring) throws -> Self {
        var typeNode: Self
        if remainder.tryConsume("`") {
            let kind = remainder.tryConsume("`") ? GenericArgKind.method : .type
            let digits = remainder.consume(while: { $0.isNumber })
            guard let index = Int(digits), index > 0 else { throw DocumentationFormatError() }
            typeNode = .genericArg(index: index, kind: kind)
        }
        else {
            let typeReference = try DocumentationTypeReference(consuming: &remainder)
            guard case .bound = typeReference.genericity else { throw DocumentationFormatError() }
            typeNode = .bound(typeReference)
        }

        while true {
            if remainder.tryConsume("[") {
                guard remainder.tryConsume("]") else { throw DocumentationFormatError() }
                typeNode = .array(of: typeNode)
            }
            else if remainder.tryConsume("*") {
                typeNode = .pointer(to: typeNode)
            }
            else {
                break
            }
        }

        return typeNode
    }
}