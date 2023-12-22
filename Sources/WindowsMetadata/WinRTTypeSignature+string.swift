import struct Foundation.UUID

extension WinRTTypeSignature {
    public func toString() -> String {
        var string = ""
        appendString(&string)
        return string
    }

    public func appendString(_ string: inout String) {
        switch self {
            case let .interface(id, args):
                if args.isEmpty {
                    appendGuid(id, to: &string)
                }
                else {
                    appendParameterizedInterface(id, args: args, to: &string)
                }

            case let .delegate(id, args):
                if args.isEmpty {
                    string.append("delegate(")
                    appendGuid(id, to: &string)
                    string.append(")")
                }
                else {
                    appendParameterizedInterface(id, args: args, to: &string)
                }

            case let .baseType(baseType):
                string.append(baseType.rawValue)

            case .comInterface:
                string.append("cinterface(IInspectable)")

            case let .interfaceGroup(name, defaultInterface):
                string.append("ig(")
                string.append(name)
                string.append(";")
                defaultInterface.appendString(&string)
                string.append(")")

            case let .runtimeClass(name, defaultInterface):
                string.append("rc(")
                string.append(name)
                string.append(";")
                defaultInterface.appendString(&string)
                string.append(")")

            case let .struct(name, fields):
                string.append("struct(")
                string.append(name)
                for field in fields {
                    string.append(";")
                    field.appendString(&string)
                }
                string.append(")")

            case let .enum(name, flags):
                string.append("enum(")
                string.append(name)
                string.append(";")
                string.append(flags ? "u4" : "i4")
                string.append(")")
        }
    }
}

fileprivate func appendParameterizedInterface(_ id: UUID, args: [WinRTTypeSignature], to string: inout String) {
    string.append("pinterface(")
    appendGuid(id, to: &string)
    for arg in args {
        string.append(";")
        arg.appendString(&string)
    }
    string.append(")")
}

fileprivate func appendGuid(_ guid: UUID, to string: inout String) {
    string.append("{")
    string.append(guid.uuidString.lowercased())
    string.append("}")
}