extension Database {
    public class Tables {
        // In TableIndex order
        public let module: Table<Module>
        public let typeRef: Table<TypeRef>
        public let typeDef: Table<TypeDef>
        public let field: Table<Field>
        public let methodDef: Table<MethodDef>
        public let param: Table<Param>
        public let interfaceImpl: Table<InterfaceImpl>
        public let memberRef: Table<MemberRef>
        public let constant: Table<MemberRef>
        public let customAttribute: Table<CustomAttribute>
        public let eventMap: Table<EventMap>
        public let event: Table<Event>
        public let propertyMap: Table<PropertyMap>
        public let property: Table<Property>
        public let methodSemantics: Table<MethodSemantics>
        public let methodImpl: Table<MethodImpl>
        public let typeSpec: Table<TypeSpec>
        public let assembly: Table<Assembly>
        public let assemblyRef: Table<AssemblyRef>
        public let genericParam: Table<GenericParam>

        init(buffer: UnsafeRawBufferPointer, sizes: TableSizes) {
            var remainder = buffer
            // In TableIndex order
            module = Self.consume(&remainder, sizes)
            typeRef = Self.consume(&remainder, sizes)
            typeDef = Self.consume(&remainder, sizes)
            field = Self.consume(&remainder, sizes)
            methodDef = Self.consume(&remainder, sizes)
            param = Self.consume(&remainder, sizes)
            interfaceImpl = Self.consume(&remainder, sizes)
            memberRef = Self.consume(&remainder, sizes)
            constant = Self.consume(&remainder, sizes)
            customAttribute = Self.consume(&remainder, sizes)
            eventMap = Self.consume(&remainder, sizes)
            event = Self.consume(&remainder, sizes)
            propertyMap = Self.consume(&remainder, sizes)
            property = Self.consume(&remainder, sizes)
            methodSemantics = Self.consume(&remainder, sizes)
            methodImpl = Self.consume(&remainder, sizes)
            typeSpec = Self.consume(&remainder, sizes)
            assembly = Self.consume(&remainder, sizes)
            assemblyRef = Self.consume(&remainder, sizes)
            genericParam = Self.consume(&remainder, sizes)
        }

        static func consume<Row>(_ buffer: inout UnsafeRawBufferPointer, _ sizes: TableSizes) -> Table<Row> where Row: TableRow {
            let rowCount = sizes.getRowCount(Row.tableIndex)
            let size = Row.getSize(sizes: sizes) * rowCount
            return Table(buffer: buffer.consume(count: size), sizes: sizes)
        }
    }
}