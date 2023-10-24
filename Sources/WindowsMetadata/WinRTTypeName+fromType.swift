import DotNetMetadata

extension WinRTTypeName {
    public static func from(type: BoundType) -> WinRTTypeName? {
        if type.definition.namespace == "System" {
            guard type.genericArgs.isEmpty else { return nil }
            guard let primitiveType = WinRTPrimitiveType.fromSystemType(name: type.definition.name) else { return nil }
            return .primitive(primitiveType)
        }

        if type.definition.genericArity > 0 {
            guard let parameterizedType = WinRTParameterizedType.from(
                namespace: type.definition.namespace ?? "", name: type.definition.name) else { return nil }

            var genericArgs = [WinRTTypeName]()
            for genericArg in type.genericArgs {
                guard case .bound(let genericArgBoundType) = genericArg,
                    let genericArgWinRTTypeName = from(type: genericArgBoundType) else { return nil }
                genericArgs.append(genericArgWinRTTypeName)
            }
            return .parameterized(parameterizedType, args: genericArgs)
        }

        return .declared(namespace: type.definition.namespace, name: type.definition.name)
    }
}