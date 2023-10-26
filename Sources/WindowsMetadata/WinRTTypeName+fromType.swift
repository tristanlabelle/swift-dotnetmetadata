import DotNetMetadata

extension WinRTTypeName {
    public static func from(type: BoundType) -> WinRTTypeName? {
        if type.definition.namespace == "System" {
            guard type.genericArgs.isEmpty else { return nil }
            guard let primitiveType = WinRTPrimitiveType.fromSystemType(name: type.definition.name) else { return nil }
            return .primitive(primitiveType)
        }

        // https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system
        // > All types—except for the fundamental types—must be contained within a namespace.
        // > It's not valid for a type to be in the global namespace.
        guard let namespace = type.definition.namespace else { return nil }

        // Delegates are not IInspectable, so they don't have to report a runtime class name,
        // their only name is in the context of midl, which prepends an "I" prefix and treats them as interfaces.
        let name = type.definition is DelegateDefinition
            ? "I" + type.definition.name : type.definition.name

        if type.definition.genericArity > 0 {
            guard let parameterizedType = WinRTParameterizedType.from(
                namespace: type.definition.namespace ?? "", name: name) else { return nil }

            var genericArgs = [WinRTTypeName]()
            for genericArg in type.genericArgs {
                guard case .bound(let genericArgBoundType) = genericArg,
                    let genericArgWinRTTypeName = from(type: genericArgBoundType) else { return nil }
                genericArgs.append(genericArgWinRTTypeName)
            }
            return .parameterized(parameterizedType, args: genericArgs)
        }

        return .declared(namespace: namespace, name: name)
    }
}