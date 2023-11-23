/// Thrown when a type appears in a context where it is not expected.
/// For example, if a class inherits from an array type.
public struct UnexpectedTypeError: Error, CustomStringConvertible {
    /// The type that was not expected
    public var type: String?
    /// The context in which the type appeared
    public var context: String?
    /// The reason why the type was not expected
    public var reason: String?

    public init(_ type: String? = nil, context: String? = nil, reason: String? = nil) {
        self.context = context
        self.type = type
        self.reason = reason
    }

    public var description: String {
        var result = "Unexpected type"
        if let type = type { result += " '\(type)'" }
        if let context = context { result += " in '\(context)'" }
        if let reason = reason { result += ": \(reason)" }
        return result
    }
}