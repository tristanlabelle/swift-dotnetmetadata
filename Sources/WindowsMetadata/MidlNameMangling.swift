public enum MidlNameMangling {
    public static let interfaceIDPrefix = "IID_"
    public static let virtualTableSuffix = "Vtbl"

    public static func get(_ systemType: WinRTSystemType) -> String {
        switch systemType {
            case .boolean: return "boolean"
            case .integer(let type):
                switch type {
                    case .uint8: return "UINT8"
                    case .int16: return "INT16"
                    case .uint16: return "UINT16"
                    case .int32: return "INT32"
                    case .uint32: return "UINT32"
                    case .int64: return "INT64"
                    case .uint64: return "UINT64"
                }
            case .float(let double): return double ? "double" : "float"
            case .char: return "WCHAR"
            case .guid: return "GUID"
            case .string: return "HSTRING"
            case .object: return "IInspectable"
        }
    }

    public static func get(_ typeName: WinRTTypeName) -> String {
        if case .system(let systemType) = typeName { return get(systemType) }

        var output = String()
        write(typeName, to: &output)
        return output
    }

    public static func write(_ typeName: WinRTTypeName, to output: inout some TextOutputStream) {
        write(typeName, parameter: false, to: &output)
    }

    private static func write(_ typeName: WinRTTypeName, parameter: Bool, to output: inout some TextOutputStream) {
        // __x_ABI_CWindows_CFoundation_CUri
        // __FIVector_1_Windows__CFoundation__CUri
        // __FIMap_2_HSTRING_HSTRING
        // __FIAsyncOperation_1___FIVectorView_1_HSTRING
        switch typeName {
            case let .system(systemType):
                output.write(get(systemType))

            case let .parameterized(type, args):
                writeMidlMangling(type, args: args, to: &output)

            case let .declared(namespace, name):
                if !parameter { output.write("__x_ABI_C") }

                var firstComponent = true
                func appendComponent(_ component: String) {
                    if !firstComponent {
                        output.write(parameter ? "__" : "_")
                        output.write("C")
                    }
                    output.write(component.replacing("_", with: "__z"))
                    firstComponent = false
                }

                for namespaceComponent in namespace.split(separator: ".") {
                    appendComponent(String(namespaceComponent))
                }

                appendComponent(name)
        }
    }

    private static func writeMidlMangling(_ type: WinRTParameterizedType, args: [WinRTTypeName], to output: inout some TextOutputStream) {
        output.write("__F")

        // Mangled names for delegates have an I prefix, except for the two collections changed event handler exceptions.
        if type.kind == .delegate,
                type != .collections_vectorChangedEventHandler,
                type != .collections_mapChangedEventHandler {
            output.write("I")
        }

        output.write(type.nameWithoutAritySuffix)
        output.write("_")
        output.write(String(type.arity))
        for arg in args {
            output.write("_")
            write(arg, parameter: true, to: &output)
        }
    }
}