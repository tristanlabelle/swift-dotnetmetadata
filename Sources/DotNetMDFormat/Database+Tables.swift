extension Database {
    public class Tables {
        // In TableID order
        public let module: ModuleTable
        public let typeRef: TypeRefTable
        public let typeDef: TypeDefTable
        public let field: FieldTable
        public let methodDef: MethodDefTable
        public let param: ParamTable
        public let interfaceImpl: InterfaceImplTable
        public let memberRef: MemberRefTable
        public let constant: ConstantTable
        public let customAttribute: CustomAttributeTable
        public let fieldMarshal: FieldMarshalTable
        public let declSecurity: DeclSecurityTable
        public let classLayout: ClassLayoutTable
        public let fieldLayout: FieldLayoutTable
        public let standAloneSig: StandAloneSigTable
        public let eventMap: EventMapTable
        public let event: EventTable
        public let propertyMap: PropertyMapTable
        public let property: PropertyTable
        public let methodSemantics: MethodSemanticsTable
        public let methodImpl: MethodImplTable
        public let moduleRef: ModuleRefTable
        public let typeSpec: TypeSpecTable
        public let implMap: ImplMapTable
        public let fieldRva: FieldRvaTable
        public let assembly: AssemblyTable
        public let assemblyRef: AssemblyRefTable
        public let file: FileTable
        public let manifestResource: ManifestResourceTable
        public let nestedClass: NestedClassTable
        public let genericParam: GenericParamTable
        public let methodSpec: MethodSpecTable
        public let genericParamConstraint: GenericParamConstraintTable

        init(buffer: UnsafeRawBufferPointer, sizes: TableSizes, sortedBits: UInt64) {
            var remainder = buffer
            var nextTableIndex = 0

            // We must read all tables in order and without any gaps
            func consume<Row: TableRow>() -> Table<Row> {
                // Make sure we're not skipping any tables with non-zero rows
                while nextTableIndex < Row.tableID.rawValue {
                    guard sizes.getRowCount(nextTableIndex) == 0
                    else { fatalError("Not implemented: reading \(TableID(rawValue: UInt8(nextTableIndex))!) metadata table") }
                    nextTableIndex += 1
                }

                let rowCount = sizes.getRowCount(Row.tableID)
                let size = Row.getSize(sizes: sizes) * rowCount
                let sorted = ((sortedBits >> Row.tableID.rawValue) & 1) == 1
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
            standAloneSig = consume()
            eventMap = consume()
            event = consume()
            propertyMap = consume()
            property = consume()
            methodSemantics = consume()
            methodImpl = consume()
            moduleRef = consume()
            typeSpec = consume()
            implMap = consume()
            fieldRva = consume()
            assembly = consume()
            assemblyRef = consume()
            file = consume()
            manifestResource = consume()
            nestedClass = consume()
            genericParam = consume()
            methodSpec = consume()
            genericParamConstraint = consume()
        }
    }
}