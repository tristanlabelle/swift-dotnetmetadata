import DotNetMetadataFormat

public final class Attribute {
    public unowned let assembly: Assembly
    internal let tableRowIndex: CustomAttributeTable.RowIndex

    init(tableRowIndex: CustomAttributeTable.RowIndex, assembly: Assembly) {
        self.tableRowIndex = tableRowIndex
        self.assembly = assembly
    }

    internal var moduleFile: ModuleFile { assembly.moduleFile }
    private var tableRow: CustomAttributeTable.Row { moduleFile.customAttributeTable[tableRowIndex] }

    private lazy var _constructor = Result {
        try assembly.resolve(tableRow.type) as! Constructor
    }
    public var constructor: Constructor { get throws { try _constructor.get() } }
    public var type: TypeDefinition { get throws { try constructor.definingType } }

    private lazy var _signature = Result {
        try CustomAttribSig(blob: moduleFile.resolve(tableRow.value), params: try _constructor.get().signature.params)
    }
    public var signature: CustomAttribSig { get throws { try _signature.get() } }

    private lazy var _arguments = Result {
        try signature.fixedArgs.map { try resolve($0) }
    }
    public var arguments: [Value] { get throws { try _arguments.get() } }

    private lazy var _namedArguments = Result {
        try signature.namedArgs.map { try resolve($0) }
    }
    public var namedArguments: [NamedArgument] { get throws { try _namedArguments.get() } }

    private func resolve(_ elem: CustomAttribSig.Elem) throws -> Value {
        switch elem {
            case .constant(let constant): return .constant(constant)

            case let .type(fullName, assemblyIdentity):
                let assembly = try assembly.context.load(identity: assemblyIdentity)
                return .type(definition: assembly.findDefinedType(fullName: fullName)!)

            case .array(let elems): return .array(try elems.map(resolve))
            case .boxed(_): fatalError("Not implemented: boxed custom attribute arguments")
        }
    }

    private func resolve(_ namedArg: CustomAttribSig.NamedArg) throws -> NamedArgument {
        let target: NamedArgument.Target
        switch namedArg.memberKind {
            case .field: target = .field(try type.findField(name: namedArg.name)!)
            case .property: target = .property(try type.findProperty(name: namedArg.name)!)
        }

        return NamedArgument(target: target, value: try resolve(namedArg.value))
    }

    public struct NamedArgument: Hashable {
        public var target: Target
        public var value: Value

        public enum Target: Hashable {
            case property(Property)
            case field(Field)
        }
    }

    public enum Value: Hashable {
        case constant(Constant)
        case type(definition: TypeDefinition)
        case array([Value])
    }
}