import DotNetMetadata

extension WinRTTypeName {
    public static func from(type: BoundType) throws -> WinRTTypeName {
        if type.definition.namespace == "System" {
            guard type.genericArgs.isEmpty else { throw WinMDError.unexpectedType }
            guard let primitiveType = WinRTPrimitiveType.fromSystemType(name: type.definition.name) else { throw WinMDError.unexpectedType }
            return .primitive(primitiveType)
        }

        // https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system
        // > All types—except for the fundamental types—must be contained within a namespace.
        // > It's not valid for a type to be in the global namespace.
        guard let namespace = type.definition.namespace else { throw WinMDError.unexpectedType }

        if type.definition.genericArity > 0 {
            guard let parameterizedType = WinRTParameterizedType.from(
                namespace: namespace, name: type.definition.name) else { throw WinMDError.unexpectedType }

            var genericArgs = [WinRTTypeName]()
            for genericArg in type.genericArgs {
                guard case .bound(let genericArgBoundType) = genericArg else { throw WinMDError.unexpectedType }
                genericArgs.append(try from(type: genericArgBoundType))
            }
            return .parameterized(parameterizedType, args: genericArgs)
        }

        return .declared(
            namespace: namespace,
            name: type.definition is DelegateDefinition ? "I" + type.definition.name : type.definition.name)
    }
}