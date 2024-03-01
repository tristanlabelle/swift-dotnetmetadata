import DotNetMetadataFormat

public class ParamBase: Attributable {
    public unowned let method: Method
    public let signature: DotNetMetadataFormat.ParamSig

    fileprivate init(method: Method, signature: DotNetMetadataFormat.ParamSig) {
        self.method = method
        self.signature = signature
    }

    public var assembly: Assembly { method.assembly }
    public var context: AssemblyLoadContext { assembly.context }
    internal var moduleFile: ModuleFile { method.moduleFile }

    public var metadataToken: MetadataToken { fatalError() }
    public var isByRef: Bool { signature.byRef }

    private lazy var _type = Result {
        try assembly.resolveTypeSig(signature.type, typeContext: method.definingType, methodContext: method)
    }
    public var type: TypeNode { get throws { try _type.get() } }

    public var attributeTarget: AttributeTargets { fatalError() }
    public private(set) lazy var attributes: [Attribute] = {
        guard !metadataToken.isNull else { return [] }
        return assembly.getAttributes(owner: .init(tag: .param, rowIndex: metadataToken.rowIndex))
    }()
}

public final class Param: ParamBase {
    internal let tableRowIndex: TableRowIndex // In Param table

    init(method: Method, tableRowIndex: TableRowIndex, signature: DotNetMetadataFormat.ParamSig) {
        self.tableRowIndex = tableRowIndex
        super.init(method: method, signature: signature)
    }

    private var tableRow: ParamTable.Row { moduleFile.paramTable[tableRowIndex] }

    public override var metadataToken: MetadataToken { .init(tableID: .param, rowIndex: tableRowIndex) }

    public var name: String? { moduleFile.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.sequence) - 1 }

    public var isIn: Bool { tableRow.flags.contains(.in) }
    public var isOut: Bool { tableRow.flags.contains(.out) }
    public var isOptional: Bool { tableRow.flags.contains(.optional) }

    private lazy var _defaultValue = Result {
        guard tableRow.flags.contains(.hasDefault) else { return nil as Constant? }
        return try Constant(moduleFile: moduleFile, owner: .init(tag: .param, rowIndex: tableRowIndex))
    }
    public var defaultValue : Constant? { get throws { try _defaultValue.get() } }

    public override var attributeTarget: AttributeTargets { .parameter }
}

public final class ReturnParam: ParamBase {
    internal let tableRowIndex: TableRowIndex? // In Param table

    init(method: Method, tableRowIndex: TableRowIndex?, signature: DotNetMetadataFormat.ParamSig) {
        self.tableRowIndex = tableRowIndex
        super.init(method: method, signature: signature)
    }

    public override var metadataToken: MetadataToken { .init(tableID: .param, rowIndex: tableRowIndex) }

    public var isVoid: Bool {
        switch signature.type {
            case .void: return true
            default: return false
        }
    }

    public override var attributeTarget: AttributeTargets { .returnValue }
}

extension ParamBase: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: ParamBase, rhs: ParamBase) -> Bool { lhs === rhs }
}