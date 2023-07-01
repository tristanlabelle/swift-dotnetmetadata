import DotNetMDFormat

public class Method {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: Table<DotNetMDFormat.MethodDef>.RowIndex

    fileprivate init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.MethodDef>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    internal static func create(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.MethodDef>.RowIndex) -> Method {
        let name = definingTypeImpl.database.heaps.resolve(definingTypeImpl.database.tables.methodDef[tableRowIndex].name)
        if name == ".ctor" {
            return Constructor(definingTypeImpl: definingTypeImpl, tableRowIndex: tableRowIndex)
        }
        else {
            return Method(definingTypeImpl: definingTypeImpl, tableRowIndex: tableRowIndex)
        }
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal var database: Database { definingTypeImpl.database }
    private var tableRow: DotNetMDFormat.MethodDef { database.tables.methodDef[tableRowIndex] }

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

    private lazy var signature = Result { try MethodDefSig(blob: database.heaps.resolve(tableRow.signature)) }

    private lazy var returnAndParams: Result<(ReturnParam, [Param]), any Error> = Result { [self] in
        let paramRowIndices = getChildRowRange(
            parent: database.tables.methodDef,
            parentRowIndex: tableRowIndex,
            childTable: database.tables.param,
            childSelector: { $0.paramList })

        let signature = try self.signature.get()

        if paramRowIndices.isEmpty || database.tables.param[paramRowIndices.lowerBound].sequence > 0 {
            // No Param row for the return param
            guard paramRowIndices.count == signature.params.count else {
                fatalError("Mismatch in number of parameters: \(paramRowIndices.count) in Param table (no return param), \(signature.params.count) in signature")
            }
            return (
                ReturnParam(method: self, tableRowIndex: nil, signature: signature.returnParam),
                zip(paramRowIndices, signature.params).map { Param(method: self, tableRowIndex: $0, signature: $1) })
        }
        else {
            // First Param row is the return param
            guard paramRowIndices.count == signature.params.count + 1 else {
                fatalError("Mismatch in number of parameters: \(paramRowIndices.count) in Param table (includes return param), \(signature.params.count) in signature")
            }
            return (
                ReturnParam(method: self, tableRowIndex: paramRowIndices.lowerBound, signature: signature.returnParam),
                zip(paramRowIndices.dropFirst(), signature.params).map { Param(method: self, tableRowIndex: $0, signature: $1) })
        }
    }

    public var returnParam: ReturnParam { get throws { try returnAndParams.get().0 } }
    public var params: [Param] { get throws { try returnAndParams.get().1 } }

    public var returnType: BoundType { get throws { try returnParam.type } }

    public private(set) lazy var genericParams: [GenericMethodParam] = {
        GenericParam.resolve(from: database, forOwner: .methodDef(tableRowIndex)) {
            GenericMethodParam(definingMethod: self, tableRowIndex: $0)
        }
    }()
}

public final class Constructor: Method {

}