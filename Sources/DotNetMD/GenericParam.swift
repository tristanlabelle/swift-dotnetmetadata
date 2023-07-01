import DotNetMDFormat

public class GenericParam {
    internal let tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex

    init(tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex) {
        self.tableRowIndex = tableRowIndex
    }

    internal var assemblyImpl: Assembly.MetadataImpl { fatalError() }
    internal var database: Database { fatalError() }
    private var tableRow: DotNetMDFormat.GenericParam { database.tables.genericParam[tableRowIndex] }

    public var name: String { database.heaps.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.number) }

    public var isReferenceType: Bool { tableRow.flags.contains(.referenceTypeConstraint) }
    public var isValueType: Bool { tableRow.flags.contains(.notNullableValueTypeConstraint) }
    public var hasDefaultConstructor: Bool { tableRow.flags.contains(.defaultConstructorConstraint) }

    private lazy var _constraints = Result {
        let key = MetadataToken(tableRowIndex).tableKey
        var result: [BoundType] = []
        guard var constraintRowIndex = database.tables.genericParamConstraint
            .findFirst(primaryKey: key) else { return result }
        while constraintRowIndex != database.tables.genericParamConstraint.endIndex {
            let constraintRow = database.tables.genericParamConstraint[constraintRowIndex]
            guard constraintRow.primaryKey == key else { break }
            result.append(assemblyImpl.resolve(constraintRow.constraint)!)
            constraintRowIndex = database.tables.genericParamConstraint.index(after: constraintRowIndex)
        }

        return result
    }

    public var constraints: [BoundType] { get throws { try _constraints.get() } }

    internal static func resolve<ConcreteGenericParam: DotNetMD.GenericParam>(
        from database: Database,
        forOwner owner: TypeOrMethodDef,
        factory: (Table<DotNetMDFormat.GenericParam>.RowIndex) -> ConcreteGenericParam) -> [ConcreteGenericParam] {

        let primaryKey = owner.metadataToken.tableKey
        var result: [ConcreteGenericParam] = []
        guard var genericParamRowIndex = database.tables.genericParam
            .findFirst(primaryKey: primaryKey, secondaryKey: 0) else { return result }
        while genericParamRowIndex < database.tables.genericParam.endIndex {
            let genericParam = database.tables.genericParam[genericParamRowIndex]
            guard genericParam.primaryKey == primaryKey && genericParam.number == result.count else { break }
            result.append(factory(genericParamRowIndex))
            genericParamRowIndex = database.tables.genericParam.index(after: genericParamRowIndex)
        }
        return result
    }
}

public final class GenericTypeParam: GenericParam {
    internal unowned let definingTypeImpl: TypeDefinition.MetadataImpl

    init(definingTypeImpl: TypeDefinition.MetadataImpl, tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex) {
        self.definingTypeImpl = definingTypeImpl
        super.init(tableRowIndex: tableRowIndex)
    }

    public var definingType: TypeDefinition { definingTypeImpl.owner }
    internal override var assemblyImpl: Assembly.MetadataImpl { definingTypeImpl.assemblyImpl }
    internal override var database: Database { definingTypeImpl.database }
}

public final class GenericMethodParam: GenericParam {
    public let definingMethod: Method

    init(definingMethod: Method, tableRowIndex: Table<DotNetMDFormat.GenericParam>.RowIndex) {
        self.definingMethod = definingMethod
        super.init(tableRowIndex: tableRowIndex)
    }

    internal override var assemblyImpl: Assembly.MetadataImpl { definingMethod.assemblyImpl }
    internal override var database: Database { definingMethod.database }
}
