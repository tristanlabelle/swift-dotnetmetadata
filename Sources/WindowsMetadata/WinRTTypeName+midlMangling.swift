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
        writeMidlManglingInner(parameter: false, to: &output)
    }

    public func writeMidlManglingInner(parameter: Bool, to output: inout some TextOutputStream) {
        // __FIMap_2_HSTRING___FIVectorView_1_Windows__CData__CText__CTextSegment
        switch self {
            case let .primitive(primitiveType):
                output.write(primitiveType.midlName)

            case let .parameterized(type, args):
                output.write("__F")
                output.write(type.nameWithoutAritySuffix)
                output.write("_")
                output.write(String(type.arity))
                output.write("_")
                for (index, genericArg) in args.enumerated() {
                    if index > 0 { output.write("_") }
                    genericArg.writeMidlManglingInner(parameter: true, to: &output)
                }

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

                if let namespace = namespace {
                    for namespaceComponent in namespace.split(separator: ".") {
                        appendComponent(String(namespaceComponent))
                    }
                }

                appendComponent(name)
        }
    }
}