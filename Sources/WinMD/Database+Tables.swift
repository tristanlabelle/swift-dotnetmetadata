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

        init(buffer: UnsafeRawBufferPointer, dimensions: Dimensions) {
            var remainder = buffer
            module = Self.consume(&remainder, dimensions)
            typeRef = Self.consume(&remainder, dimensions)
            typeDef = Self.consume(&remainder, dimensions)
            field = Self.consume(&remainder, dimensions)
            methodDef = Self.consume(&remainder, dimensions)
            param = Self.consume(&remainder, dimensions)
            interfaceImpl = Self.consume(&remainder, dimensions)
            memberRef = Self.consume(&remainder, dimensions)
            constant = Self.consume(&remainder, dimensions)
        }

        static func consume<Row>(_ buffer: inout UnsafeRawBufferPointer, _ dimensions: Dimensions) -> Table<Row> where Row: Record {
            let rowCount = dimensions.getRowCount(Row.tableIndex)
            let size = Row.getSize(dimensions: dimensions) * rowCount
            return Table(buffer: buffer.consume(count: size), dimensions: dimensions)
        }
    }
}