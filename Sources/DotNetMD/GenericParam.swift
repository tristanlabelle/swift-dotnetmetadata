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

    private lazy var _constraints = Result { [self] in
        var result: [BoundType] = []
        guard var constraintRowIndex = database.tables.genericParamConstraint
            .findFirst(primaryKey: MetadataToken(tableRowIndex)) else { return result }
        while constraintRowIndex != database.tables.genericParamConstraint.endIndex {
            let constraintRow = database.tables.genericParamConstraint[constraintRowIndex]
            guard constraintRow.primaryKey == MetadataToken(tableRowIndex) else { break }
            result.append(assemblyImpl.resolve(constraintRow.constraint)!)
            constraintRowIndex = database.tables.genericParamConstraint.index(after: constraintRowIndex)
        }

        return result
    }

    public var constraints: [BoundType] { get throws { try _constraints.get() } }
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
