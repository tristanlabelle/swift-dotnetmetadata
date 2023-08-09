import DotNetMetadataFormat

/// An unbound method definition, which may have generic parameters.
public class Method: Member {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl
    internal let tableRowIndex: MethodDefTable.RowIndex

    fileprivate init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: MethodDefTable.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        self.tableRowIndex = tableRowIndex
    }

    internal static func create(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: MethodDefTable.RowIndex) -> Method {
        let name = definingTypeImpl.moduleFile.resolve(definingTypeImpl.moduleFile.methodDefTable[tableRowIndex].name)
        if name == Constructor.name {
            return Constructor(definingTypeImpl: definingTypeImpl, tableRowIndex: tableRowIndex)
        }
        else {
            return Method(definingTypeImpl: definingTypeImpl, tableRowIndex: tableRowIndex)
        }
    }

    public override var definingType: TypeDefinition { definingTypeImpl.owner }
    internal var assemblyImpl: MetadataAssemblyImpl { definingTypeImpl.assemblyImpl }
    internal var moduleFile: ModuleFile { definingTypeImpl.moduleFile }
    private var tableRow: MethodDefTable.Row { moduleFile.methodDefTable[tableRowIndex] }

    public override var name: String { moduleFile.resolve(tableRow.name) }
    public override var isStatic: Bool { tableRow.flags.contains(.`static`) }
    public var isVirtual: Bool { tableRow.flags.contains(.virtual) }
    public var isAbstract: Bool { tableRow.flags.contains(.abstract) }
    public var isFinal: Bool { tableRow.flags.contains(.final) }
    public var isSpecialName: Bool { tableRow.flags.contains(.specialName) }
    public var isGeneric: Bool { !genericParams.isEmpty }

    public override var visibility: Visibility {
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

    private lazy var _signature = Result { try MethodDefSig(blob: moduleFile.resolve(tableRow.signature)) }
    public var signature: MethodDefSig { get throws { try _signature.get() } }

    private lazy var returnAndParams: Result<(ReturnParam, [Param]), any Error> = Result {
        let paramRowIndices = getChildRowRange(
            parent: moduleFile.methodDefTable,
            parentRowIndex: tableRowIndex,
            childTable: moduleFile.paramTable,
            childSelector: { $0.paramList })

        let signature = try self.signature

        if paramRowIndices.isEmpty || moduleFile.paramTable[paramRowIndices.lowerBound].sequence > 0 {
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
    public var arity: Int { get throws { try signature.params.count } }

    public var hasReturnValue: Bool {
        get throws {
            switch try signature.returnParam.type {
                case .void: return false
                default: return true
            }
        }
    }

    public var returnType: TypeNode { get throws { try returnParam.type } }

    public private(set) lazy var genericParams: [GenericMethodParam] = {
        moduleFile.genericParamTable.findAll(primaryKey: tableRowIndex.metadataToken.tableKey).map {
            GenericMethodParam(definingMethod: self, tableRowIndex: $0)
        }
    }()

    public var genericArity: Int { genericParams.count }

    public private(set) lazy var attributes: [Attribute] = {
        assemblyImpl.getAttributes(owner: .methodDef(tableRowIndex))
    }()
}

public final class Constructor: Method {
    public static let name: String = ".ctor"
}

extension Method: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: Method, rhs: Method) -> Bool { lhs === rhs }
}