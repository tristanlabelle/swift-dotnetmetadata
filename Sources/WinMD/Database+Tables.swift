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

        init(buffer: UnsafeRawBufferPointer, dimensions: Dimensions) {
            var remainder = buffer
            // In TableIndex order
            module = Self.consume(&remainder, dimensions)
            typeRef = Self.consume(&remainder, dimensions)
            typeDef = Self.consume(&remainder, dimensions)
            field = Self.consume(&remainder, dimensions)
            methodDef = Self.consume(&remainder, dimensions)
            param = Self.consume(&remainder, dimensions)
            interfaceImpl = Self.consume(&remainder, dimensions)
            memberRef = Self.consume(&remainder, dimensions)
            constant = Self.consume(&remainder, dimensions)
            customAttribute = Self.consume(&remainder, dimensions)
            eventMap = Self.consume(&remainder, dimensions)
            event = Self.consume(&remainder, dimensions)
            propertyMap = Self.consume(&remainder, dimensions)
            property = Self.consume(&remainder, dimensions)
            methodSemantics = Self.consume(&remainder, dimensions)
            methodImpl = Self.consume(&remainder, dimensions)
            typeSpec = Self.consume(&remainder, dimensions)
            assembly = Self.consume(&remainder, dimensions)
            assemblyRef = Self.consume(&remainder, dimensions)
        }

        static func consume<Row>(_ buffer: inout UnsafeRawBufferPointer, _ dimensions: Dimensions) -> Table<Row> where Row: Record {
            let rowCount = dimensions.getRowCount(Row.tableIndex)
            let size = Row.getSize(dimensions: dimensions) * rowCount
            return Table(buffer: buffer.consume(count: size), dimensions: dimensions)
        }
    }
}