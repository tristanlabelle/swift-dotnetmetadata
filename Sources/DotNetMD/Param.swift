import DotNetMDFormat

public class ParamBase {
    public unowned let method: Method
    fileprivate let signature: DotNetMDFormat.ParamSig

    fileprivate init(method: Method, signature: DotNetMDFormat.ParamSig) {
        self.method = method
        self.signature = signature
    }

    internal var assemblyImpl: Assembly.MetadataImpl { method.assemblyImpl }
    internal var database: Database { method.database }

    public var isByRef: Bool { signature.byRef }

    public private(set) lazy var type: BoundType = assemblyImpl.resolve(signature.type, typeContext: method.definingType, methodContext: method)
}

public final class Param: ParamBase {
    internal let tableRowIndex: Table<DotNetMDFormat.Param>.RowIndex

    init(method: Method, tableRowIndex: Table<DotNetMDFormat.Param>.RowIndex, signature: DotNetMDFormat.ParamSig) {
        self.tableRowIndex = tableRowIndex
        super.init(method: method, signature: signature)
    }

    private var tableRow: DotNetMDFormat.Param { database.tables.param[tableRowIndex] }

    public var name: String? { database.heaps.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.sequence) - 1 }

    public var isIn: Bool { tableRow.flags.contains(.in) }
    public var isOut: Bool { tableRow.flags.contains(.out) }
    public var isOptional: Bool { tableRow.flags.contains(.optional) }
}

public final class ReturnParam: ParamBase {
    internal let tableRowIndex: Table<DotNetMDFormat.Param>.RowIndex?

    init(method: Method, tableRowIndex: Table<DotNetMDFormat.Param>.RowIndex?, signature: DotNetMDFormat.ParamSig) {
        self.tableRowIndex = tableRowIndex
        super.init(method: method, signature: signature)
    }
}