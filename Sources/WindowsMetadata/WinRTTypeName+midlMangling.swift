extension WinRTTypeName {
    public static let midlInterfaceIDPrefix = "IID_"
    public static let midlVirtualTableSuffix = "Vtbl"

    public var midlMangling: String {
        if case .primitive(let primitiveType) = self { return primitiveType.midlName }

        var output = String()
        writeMidlMangling(to: &output)
        return output
    }

    public func writeMidlMangling(to output: inout some TextOutputStream) {
        writeMidlMangling(parameter: false, to: &output)
    }

    private func writeMidlMangling(parameter: Bool, to output: inout some TextOutputStream) {
        // __x_ABI_CWindows_CFoundation_CUri
        // __FIVector_1_Windows__CFoundation__CUri
        // __FIMap_2_HSTRING_HSTRING
        // __FIAsyncOperation_1___FIVectorView_1_HSTRING
        switch self {
            case let .primitive(primitiveType):
                output.write(primitiveType.midlName)

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

    private func writeMidlMangling(_ type: WinRTParameterizedType, args: [WinRTTypeName], to output: inout some TextOutputStream) {
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
            arg.writeMidlMangling(parameter: true, to: &output)
        }
    }
}