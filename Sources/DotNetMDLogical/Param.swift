import DotNetMDPhysical

public final class Param {
    public unowned let method: Method
    private let tableRowIndex: Table<DotNetMDPhysical.Param>.RowIndex
    private let signature: DotNetMDPhysical.ParamSig

    init(method: Method, tableRowIndex: Table<DotNetMDPhysical.Param>.RowIndex, signature: DotNetMDPhysical.ParamSig) {
        self.method = method
        self.tableRowIndex = tableRowIndex
        self.signature = signature
    }

    internal var assemblyImpl: Assembly.MetadataImpl { method.assemblyImpl }
    internal var database: Database { method.database }
    private var tableRow: DotNetMDPhysical.Param { database.tables.param[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.sequence) }

    public private(set) lazy var type: Type = assemblyImpl.resolve(signature.type)
}