import DotNetMDFormat

public class GenericParam {
    internal let tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex

    init(tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex) {
        self.tableRowIndex = tableRowIndex
    }

    internal var database: Database { fatalError() }
    private var tableRow: DotNetMDFormat.GenericParam { database.tables.genericParam[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.number) }
}

public final class GenericTypeParam: GenericParam {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        super.init(tableRowIndex: tableRowIndex)
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal override var database: Database { definingTypeImpl.database }
}

public final class GenericMethodParam: GenericParam {
    public let definingMethod: Method

    init(definingMethod: Method, tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex) {
        self.definingMethod = definingMethod
        super.init(tableRowIndex: tableRowIndex)
    }

    internal override var database: Database { definingMethod.database }
}
