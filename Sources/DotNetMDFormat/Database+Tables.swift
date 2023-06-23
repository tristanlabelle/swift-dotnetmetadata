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
        public let constant: Table<Constant>
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
        public let genericParamConstraint: Table<GenericParamConstraint>

        init(buffer: UnsafeRawBufferPointer, sizes: TableSizes, sortedBits: UInt64) {
            var remainder = buffer
            // In TableIndex order
            module = Self.consume(&remainder, sizes, sortedBits)
            typeRef = Self.consume(&remainder, sizes, sortedBits)
            typeDef = Self.consume(&remainder, sizes, sortedBits)
            field = Self.consume(&remainder, sizes, sortedBits)
            methodDef = Self.consume(&remainder, sizes, sortedBits)
            param = Self.consume(&remainder, sizes, sortedBits)
            interfaceImpl = Self.consume(&remainder, sizes, sortedBits)
            memberRef = Self.consume(&remainder, sizes, sortedBits)
            constant = Self.consume(&remainder, sizes, sortedBits)
            customAttribute = Self.consume(&remainder, sizes, sortedBits)
            eventMap = Self.consume(&remainder, sizes, sortedBits)
            event = Self.consume(&remainder, sizes, sortedBits)
            propertyMap = Self.consume(&remainder, sizes, sortedBits)
            property = Self.consume(&remainder, sizes, sortedBits)
            methodSemantics = Self.consume(&remainder, sizes, sortedBits)
            methodImpl = Self.consume(&remainder, sizes, sortedBits)
            typeSpec = Self.consume(&remainder, sizes, sortedBits)
            assembly = Self.consume(&remainder, sizes, sortedBits)
            assemblyRef = Self.consume(&remainder, sizes, sortedBits)
            genericParam = Self.consume(&remainder, sizes, sortedBits)
            genericParamConstraint = Self.consume(&remainder, sizes, sortedBits)
        }

        private static func consume<Row>(_ buffer: inout UnsafeRawBufferPointer, _ sizes: TableSizes, _ sortedBits: UInt64) -> Table<Row> where Row: TableRow {
            let rowCount = sizes.getRowCount(Row.tableIndex)
            let size = Row.getSize(sizes: sizes) * rowCount
            let sorted = ((sortedBits >> Row.tableIndex.rawValue) & 1) == 1
            return Table(buffer: buffer.consume(count: size), sizes: sizes, sorted: sorted)
        }
    }
}