import DotNetMDFormat

public final class Attribute {
    internal let assemblyImpl: Assembly.MetadataImpl
    internal let tableRowIndex: CustomAttributeTable.RowIndex

    init(tableRowIndex: CustomAttributeTable.RowIndex, assemblyImpl: Assembly.MetadataImpl) {
        self.tableRowIndex = tableRowIndex
        self.assemblyImpl = assemblyImpl
    }

    internal var database: Database { assemblyImpl.database }
    private var tableRow: CustomAttributeTable.Row { database.tables.customAttribute[tableRowIndex] }

    private lazy var _constructor = Result {
        try assemblyImpl.resolve(tableRow.type) as! Constructor
    }
    public var constructor: Constructor { get throws { try _constructor.get() } }
    public var type: TypeDefinition { get throws { try constructor.definingType } }

    private lazy var _arguments = Result {
        fatalError("Not implemented")
    }
    public var arguments: [Constant] { get throws { try _arguments.get() } }

    public struct NamedArgument {
        public var target: Target
        public var value: Constant

        public enum Target {
            case property(Property)
            case field(Field)
        }
    }
}