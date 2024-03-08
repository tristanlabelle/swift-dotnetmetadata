import DotNetMetadataFormat

public class GenericParam: Attributable {
    internal let tableRowIndex: TableRowIndex // In GenericParam table

    init(tableRowIndex: TableRowIndex) {
        self.tableRowIndex = tableRowIndex
    }

    public var assembly: Assembly { fatalError() }
    public var context: AssemblyLoadContext { assembly.context }
    internal var moduleFile: ModuleFile { fatalError() }
    private var tableRow: GenericParamTable.Row { moduleFile.genericParamTable[tableRowIndex] }

    public var name: String { moduleFile.resolve(tableRow.name) }
    public var index: Int { Int(tableRow.number) }

    public var isReferenceType: Bool { tableRow.flags.contains(.referenceTypeConstraint) }
    public var isValueType: Bool { tableRow.flags.contains(.notNullableValueTypeConstraint) }
    public var hasDefaultConstructor: Bool { tableRow.flags.contains(.defaultConstructorConstraint) }

    private var cachedConstraints: [TypeNode]?
    public var constraints: [TypeNode] { get throws {
        try cachedConstraints.lazyInit {
            try moduleFile.genericParamConstraintTable.findAll(primaryKey: .init(index: tableRowIndex)).map {
                try assembly.resolveTypeDefOrRef(moduleFile.genericParamConstraintTable[$0].constraint)!
            }
        }
    } }

    public var attributeTarget: AttributeTargets { .genericParameter }
    private var cachedAttributes: [Attribute]?
    public var attributes: [Attribute] {
        cachedAttributes.lazyInit {
            assembly.getAttributes(owner: .init(tag: .genericParam, rowIndex: tableRowIndex))
        }
    }

    public final func bind(typeArgs: [TypeNode]?, methodArgs: [TypeNode]?) -> TypeNode {
        switch self {
            case let typeParam as GenericTypeParam:
                guard let typeArgs else { return .genericParam(self) }
                guard typeParam.definingType.genericArity == typeArgs.count,
                    typeParam.index < typeArgs.count else {
                    assertionFailure("Generic bindings must match type generic arity")
                    return .genericParam(self)
                }

                return typeArgs[typeParam.index]

            case let methodParam as GenericMethodParam:
                guard let methodArgs else { return .genericParam(self) }
                guard methodParam.definingMethod.genericArity == methodArgs.count,
                    methodParam.index < methodArgs.count else {
                    assertionFailure("Generic bindings must match method generic arity")
                    return .genericParam(self)
                }

                return methodArgs[methodParam.index]
            
            default: fatalError("Unexpected generic param type")
        }
    }

    internal func breakReferenceCycles() {
        if let attributes = cachedAttributes {
            for attribute in attributes {
                attribute.breakReferenceCycles()
            }
        }

        cachedConstraints = nil
    }
}

public final class GenericTypeParam: GenericParam {
    public private(set) weak var definingType: TypeDefinition!

    init(definingType: TypeDefinition, tableRowIndex: TableRowIndex) {
        self.definingType = definingType
        super.init(tableRowIndex: tableRowIndex)
    }

    public override var assembly: Assembly { definingType.assembly }
    internal override var moduleFile: ModuleFile { definingType.moduleFile }
}

public final class GenericMethodParam: GenericParam {
    public let definingMethod: Method

    init(definingMethod: Method, tableRowIndex: TableRowIndex) {
        self.definingMethod = definingMethod
        super.init(tableRowIndex: tableRowIndex)
    }

    public override var assembly: Assembly { definingMethod.assembly }
    internal override var moduleFile: ModuleFile { definingMethod.moduleFile }
}

extension GenericParam: Hashable {
    public func hash(into hasher: inout Hasher) { hasher.combine(ObjectIdentifier(self)) }
    public static func == (lhs: GenericParam, rhs: GenericParam) -> Bool { lhs === rhs }
}