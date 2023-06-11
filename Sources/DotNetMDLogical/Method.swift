import DotNetMDPhysical

public final class Method {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    private let tableRowIndex: Table<DotNetMDPhysical.MethodDef>.RowIndex

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDPhysical.MethodDef>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDPhysical.MethodDef { database.tables.methodDef[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var isStatic: Bool { tableRow.flags.contains(.`static`) }
    public var isVirtual: Bool { tableRow.flags.contains(.virtual) }
    public var isAbstract: Bool { tableRow.flags.contains(.abstract) }
    public var isFinal: Bool { tableRow.flags.contains(.final) }
    public var isSpecialName: Bool { tableRow.flags.contains(.specialName) }
    public var isGeneric: Bool { !genericParams.isEmpty }

    public var visibility: Visibility {
        switch tableRow.flags.intersection(.memberAccessMask) {
            case .compilerControlled: return .compilerControlled
            case .private: return .private
            case .assem: return .assembly
            case .famANDAssem: return .familyAndAssembly
            case .famORAssem: return .familyOrAssembly
            case .family: return .family
            case .public: return .public
            default: fatalError()
        }
    }

    private lazy var signature = try! MethodDefSig(blob: database.heaps.resolve(tableRow.signature))

    public private(set) lazy var params: [Param] = { [self] in
        let paramRowIndices = getChildRowRange(
            parent: database.tables.methodDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.param,
            childSelector: { $0.paramList })
        guard paramRowIndices.count == signature.params.count else { fatalError() }
        return zip(paramRowIndices, signature.params).map { Param(method: self, tableRowIndex: $0, signature: $1) }
    }()

    public private(set) lazy var genericParams: [GenericMethodParam] = { [self] in
        var result: [GenericMethodParam] = []
        var genericParamRowIndex = database.tables.genericParam.find(primaryKey: MetadataToken(tableRowIndex), secondaryKey: 0)
            ?? database.tables.genericParam.endIndex
        while genericParamRowIndex < database.tables.genericParam.endIndex {
            let genericParam = database.tables.genericParam[genericParamRowIndex]
            guard genericParam.primaryKey == MetadataToken(tableRowIndex) && genericParam.number == result.count else { break }
            result.append(GenericMethodParam(definingMethod: self, tableRowIndex: genericParamRowIndex))
            genericParamRowIndex = database.tables.genericParam.index(after: genericParamRowIndex)
        }
        return result
    }()
}