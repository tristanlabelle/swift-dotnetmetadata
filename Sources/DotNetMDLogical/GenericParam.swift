import DotNetMDPhysical

public class GenericParam {
    private let tableRowIndex: Table<DotNetMDPhysical.GenericParam>.RowIndex

    init(tableRowIndex: Table<DotNetMDPhysical.GenericParam>.RowIndex) {
        self.tableRowIndex = tableRowIndex
    }

    internal var database: Database { fatalError() }
    private var tableRow: DotNetMDPhysical.GenericParam { database.tables.genericParam[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.number) }
}

public final class GenericTypeParam: GenericParam {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDPhysical.GenericParam>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        super.init(tableRowIndex: tableRowIndex)
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal override var database: Database { definingTypeImpl.database }
}

public final class GenericMethodParam: GenericParam {
    public let definingMethod: Method

    init(definingMethod: Method, tableRowIndex: Table<DotNetMDPhysical.GenericParam>.RowIndex) {
        self.definingMethod = definingMethod
        super.init(tableRowIndex: tableRowIndex)
    }

    internal override var database: Database { definingMethod.database }
}
