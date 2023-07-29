import DotNetMDFormat

public class GenericParam {
    internal let tableRowIndex: GenericParamTable.RowIndex

    init(tableRowIndex: GenericParamTable.RowIndex) {
        self.tableRowIndex = tableRowIndex
    }

    internal var assemblyImpl: Assembly.MetadataImpl { fatalError() }
    internal var moduleFile: ModuleFile { fatalError() }
    private var tableRow: GenericParamTable.Row { moduleFile.genericParamTable[tableRowIndex] }

    public var name: String { moduleFile.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.number) }

    public var isReferenceType: Bool { tableRow.flags.contains(.referenceTypeConstraint) }
    public var isValueType: Bool { tableRow.flags.contains(.notNullableValueTypeConstraint) }
    public var hasDefaultConstructor: Bool { tableRow.flags.contains(.defaultConstructorConstraint) }

    private lazy var _constraints = Result {
        moduleFile.genericParamConstraintTable.findAll(primaryKey: MetadataToken(tableRowIndex).tableKey).map {
            assemblyImpl.resolve(moduleFile.genericParamConstraintTable[$0].constraint)!
        }
    }

    public var constraints: [TypeNode] { get throws { try _constraints.get() } }

    public private(set) lazy var attributes: [Attribute] = {
        assemblyImpl.getAttributes(owner: .genericParam(tableRowIndex))
    }()
}

public final class GenericTypeParam: GenericParam {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: GenericParamTable.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        super.init(tableRowIndex: tableRowIndex)
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal override var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal override var moduleFile: ModuleFile { definingTypeImpl.moduleFile }
}

public final class GenericMethodParam: GenericParam {
    public let definingMethod: Method

    init(definingMethod: Method, tableRowIndex: GenericParamTable.RowIndex) {
        self.definingMethod = definingMethod
        super.init(tableRowIndex: tableRowIndex)
    }

    internal override var assemblyImpl: Assembly.MetadataImpl { definingMethod.assemblyImpl }
    internal override var moduleFile: ModuleFile { definingMethod.moduleFile }
}

extension GenericParam: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: GenericParam, rhs: GenericParam) -> Bool { lhs === rhs }
}