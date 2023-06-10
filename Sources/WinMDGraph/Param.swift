import WinMD

public final class Param {
    public unowned let method: Method
    private let tableRowIndex: Table<WinMD.Param>.RowIndex
    private let signature: WinMD.ParamSig

    init(method: Method, tableRowIndex: Table<WinMD.Param>.RowIndex, signature: WinMD.ParamSig) {
        self.method = method
        self.tableRowIndex = tableRowIndex
        self.signature = signature
    }

    internal var assemblyImpl: Assembly.MetadataImpl { method.assemblyImpl }
    internal var database: Database { method.database }
    private var tableRow: WinMD.Param { database.tables.param[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.sequence) }

    public private(set) lazy var type: Type = assemblyImpl.resolve(signature.type)
}