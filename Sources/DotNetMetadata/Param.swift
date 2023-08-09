import DotNetMetadataFormat

public class ParamBase {
    public unowned let method: Method
    fileprivate let signature: DotNetMetadataFormat.ParamSig

    fileprivate init(method: Method, signature: DotNetMetadataFormat.ParamSig) {
        self.method = method
        self.signature = signature
    }

    internal var assemblyImpl: MetadataAssemblyImpl { method.assemblyImpl }
    internal var moduleFile: ModuleFile { method.moduleFile }

    public var isByRef: Bool { signature.byRef }

    public private(set) lazy var type: TypeNode = assemblyImpl.resolve(signature.type, typeContext: method.definingType, methodContext: method)
}

public final class Param: ParamBase {
    internal let tableRowIndex: ParamTable.RowIndex

    init(method: Method, tableRowIndex: ParamTable.RowIndex, signature: DotNetMetadataFormat.ParamSig) {
        self.tableRowIndex = tableRowIndex
        super.init(method: method, signature: signature)
    }

    private var tableRow: ParamTable.Row { moduleFile.paramTable[tableRowIndex] }

    public var name: String? { moduleFile.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.sequence) - 1 }

    public var isIn: Bool { tableRow.flags.contains(.in) }
    public var isOut: Bool { tableRow.flags.contains(.out) }
    public var isOptional: Bool { tableRow.flags.contains(.optional) }

    private lazy var _defaultValue = Result {
        guard tableRow.flags.contains(.hasDefault) else { return nil as Constant? }
        return try Constant(moduleFile: moduleFile, owner: .param(tableRowIndex))
    }
    public var defaultValue : Constant? { get throws { try _defaultValue.get() } }
}

public final class ReturnParam: ParamBase {
    internal let tableRowIndex: ParamTable.RowIndex?

    init(method: Method, tableRowIndex: ParamTable.RowIndex?, signature: DotNetMetadataFormat.ParamSig) {
        self.tableRowIndex = tableRowIndex
        super.init(method: method, signature: signature)
    }

    public var isVoid: Bool {
        switch signature.type {
            case .void: return true
            default: return false
        }
    }
}

extension ParamBase: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: ParamBase, rhs: ParamBase) -> Bool { lhs === rhs }
}