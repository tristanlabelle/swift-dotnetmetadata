import DotNetMetadataFormat

/// An unbound method definition, which may have generic parameters.
public class Method: Member {
    internal let tableRowIndex: MethodDefTable.RowIndex
    private var tableRow: MethodDefTable.Row { moduleFile.methodDefTable[tableRowIndex] }
    private var flags: MethodAttributes { tableRow.flags }

    fileprivate init(definingType: TypeDefinition, tableRowIndex: MethodDefTable.RowIndex) {
        self.tableRowIndex = tableRowIndex
        super.init(definingType: definingType)
    }

    internal static func create(definingType: TypeDefinition, tableRowIndex: MethodDefTable.RowIndex) -> Method {
        let name = definingType.moduleFile.resolve(definingType.moduleFile.methodDefTable[tableRowIndex].name)
        if name == Constructor.name {
            return Constructor(definingType: definingType, tableRowIndex: tableRowIndex)
        }
        else {
            return Method(definingType: definingType, tableRowIndex: tableRowIndex)
        }
    }

    internal override func resolveName() -> String { moduleFile.resolve(tableRow.name) }
    public override var nameKind: NameKind { flags.nameKind }
    public override var visibility: Visibility { flags.visibility }
    public override var isStatic: Bool { flags.contains(.`static`) }
    public var isVirtual: Bool { flags.contains(.virtual) }
    public var isAbstract: Bool { flags.contains(.abstract) }
    public var isFinal: Bool { flags.contains(.final) }
    public var isHideBySig: Bool { flags.contains(.hideBySig) }
    public var isNewSlot: Bool { flags.contains(.newSlot) }
    public var isOverride: Bool { isVirtual && !isNewSlot }
    public var isSpecialName: Bool { flags.contains(.specialName) }
    public var isGeneric: Bool { !genericParams.isEmpty }

    private lazy var _signature = Result { try MethodSig(blob: moduleFile.resolve(tableRow.signature), isRef: false) }
    public var signature: MethodSig { get throws { try _signature.get() } }

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
        assembly.getAttributes(owner: .methodDef(tableRowIndex))
    }()

    public func signatureMatches(typeGenericArgs: [TypeNode]? = nil, paramTypes expectedParamTypes: [TypeNode]) -> Bool {
        guard let params = try? params, params.count == expectedParamTypes.count else { return false }
        for i in 0..<params.count {
            let expectedParamType: TypeNode
            if let typeGenericArgs {
                assert(typeGenericArgs.count == definingType.genericArity)
                expectedParamType = expectedParamTypes[i].bindGenericParams(typeArgs: typeGenericArgs, methodArgs: nil)
            }
            else {
                expectedParamType = expectedParamTypes[i]
            }

            if params[i].type != expectedParamType { return false }
        }

        return true
    }
}

public final class Constructor: Method {
    public static let name: String = ".ctor"
}
