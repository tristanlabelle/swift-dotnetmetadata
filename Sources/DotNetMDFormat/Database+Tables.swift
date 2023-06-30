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
        public let fieldMarshal: Table<FieldMarshal>
        public let declSecurity: Table<DeclSecurity>
        public let classLayout: Table<ClassLayout>
        public let fieldLayout: Table<FieldLayout>
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
            var nextTableIndex = 0

            // We must read all tables in order and without any gaps
            func consume<Row: TableRow>() -> Table<Row> {
                // Make sure we're not skipping any tables with non-zero rows
                while nextTableIndex < Row.tableIndex.rawValue {
                    guard sizes.getRowCount(nextTableIndex) == 0
                    else { fatalError("Not implemented: reading \(TableIndex(rawValue: UInt8(nextTableIndex))!) metadata table") }
                    nextTableIndex += 1
                }

                let rowCount = sizes.getRowCount(Row.tableIndex)
                let size = Row.getSize(sizes: sizes) * rowCount
                let sorted = ((sortedBits >> Row.tableIndex.rawValue) & 1) == 1
                nextTableIndex += 1
                return Table(buffer: remainder.consume(count: size), sizes: sizes, sorted: sorted)
            } 

            module = consume()
            typeRef = consume()
            typeDef = consume()
            field = consume()
            methodDef = consume()
            param = consume()
            interfaceImpl = consume()
            memberRef = consume()
            constant = consume()
            customAttribute = consume()
            fieldMarshal = consume()
            declSecurity = consume()
            classLayout = consume()
            fieldLayout = consume()
            eventMap = consume()
            event = consume()
            propertyMap = consume()
            property = consume()
            methodSemantics = consume()
            methodImpl = consume()
            typeSpec = consume()
            assembly = consume()
            assemblyRef = consume()
            genericParam = consume()
            genericParamConstraint = consume()
        }
    }
}