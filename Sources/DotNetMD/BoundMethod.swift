/// A method with all generic parameters bound to type arguments.
public struct BoundMethod {
    public let definition: Method
    public let genericArgs: [TypeNode]

    public init(_ definition: Method, genericArgs: [TypeNode]) {
        precondition(definition.genericParams.count == genericArgs.count)
        self.definition = definition
        self.genericArgs = genericArgs
    }
}

extension Method {
    public func bind(genericArgs: [TypeNode] = []) -> BoundMethod {
        .init(self, genericArgs: genericArgs)
    }
}