public enum WinRTTypeName: Hashable {
    case primitive(WinRTPrimitiveType)
    case parameterized(WinRTParameterizedType, args: [WinRTTypeName] = [])

    // https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system
    // > All types—except for the fundamental types—must be contained within a namespace.
    // > It's not valid for a type to be in the global namespace.
    case declared(namespace: String, name: String)
}

extension WinRTTypeName: CustomStringConvertible, TextOutputStreamable {
    public var description: String {
        if case .primitive(let primitiveType) = self { return primitiveType.name }

        var output = String()
        write(to: &output)
        return output
    }

    public func write(to output: inout some TextOutputStream) {
        switch self {
            case let .primitive(primitiveType):
                output.write(primitiveType.name)
            case let .parameterized(type, args: args):
                write(namespace: type.namespace, name: type.nameWithAritySuffix, genericArgs: args, to: &output)
            case let .declared(namespace, name):
                write(namespace: namespace, name: name, genericArgs: [], to: &output)
        }
    }

    private func write(namespace: String?, name: String, genericArgs: [WinRTTypeName], to output: inout some TextOutputStream) {
        if let namespace = namespace {
            output.write(namespace)
            output.write(".")
        }
        output.write(name)
        if !genericArgs.isEmpty {
            output.write("<")
            for (index, genericArg) in genericArgs.enumerated() {
                if index > 0 { output.write(", ") }
                genericArg.write(to: &output)
            }
            output.write(">")
        }
    }
}