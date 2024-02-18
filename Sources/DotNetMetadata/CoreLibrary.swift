
/// Provides access to core types of the System namespace from mscorlib.dll or System.Runtime.dll.
public class CoreLibrary {
    public let assembly: Assembly

    internal init(assembly: Assembly) {
        self.assembly = assembly
    }

    // Fundamental type system types
    private var _systemObject: ClassDefinition? = nil
    public var systemObject: ClassDefinition { get throws { try lazyInitType(&_systemObject, name: "Object") } }

    private var _systemVoid: StructDefinition? = nil
    public var systemVoid: StructDefinition { get throws { try lazyInitType(&_systemVoid, name: "Void") } }

    private var _systemValueType: ClassDefinition? = nil
    public var systemValueType: ClassDefinition { get throws { try lazyInitType(&_systemValueType, name: "ValueType") } }

    private var _systemEnum: ClassDefinition? = nil
    public var systemEnum: ClassDefinition { get throws { try lazyInitType(&_systemEnum, name: "Enum") } }

    private var _systemDelegate: ClassDefinition? = nil
    public var systemDelegate: ClassDefinition { get throws { try lazyInitType(&_systemDelegate, name: "Delegate") } }

    private var _systemMulticastDelegate: ClassDefinition? = nil
    public var systemMulticastDelegate: ClassDefinition { get throws { try lazyInitType(&_systemMulticastDelegate, name: "MulticastDelegate") } }

    private var _systemType: ClassDefinition? = nil
    public var systemType: ClassDefinition { get throws { try lazyInitType(&_systemType, name: "Type") } }

    private var _systemTypedReference: StructDefinition? = nil
    public var systemTypedReference: StructDefinition { get throws { try lazyInitType(&_systemTypedReference, name: "TypedReference") } }

    private var _systemException: ClassDefinition? = nil
    public var systemException: ClassDefinition { get throws { try lazyInitType(&_systemException, name: "Exception") } }

    private var _systemAttribute: ClassDefinition? = nil
    public var systemAttribute: ClassDefinition { get throws { try lazyInitType(&_systemAttribute, name: "Attribute") } }

    private var _systemString: ClassDefinition? = nil
    public var systemString: ClassDefinition { get throws { try lazyInitType(&_systemString, name: "String") } }

    private var _systemArray: ClassDefinition? = nil
    public var systemArray: ClassDefinition { get throws { try lazyInitType(&_systemArray, name: "Array") } }

    // Primitive types
    private var _systemBoolean: StructDefinition? = nil
    public var systemBoolean: StructDefinition { get throws { try lazyInitType(&_systemBoolean, name: "Boolean") } }

    private var _systemChar: StructDefinition? = nil
    public var systemChar: StructDefinition { get throws { try lazyInitType(&_systemChar, name: "Char") } }

    private var _systemByte: StructDefinition? = nil
    public var systemByte: StructDefinition { get throws { try lazyInitType(&_systemByte, name: "Byte") } }

    private var _systemSByte: StructDefinition? = nil
    public var systemSByte: StructDefinition { get throws { try lazyInitType(&_systemSByte, name: "SByte") } }

    private var _systemUInt16: StructDefinition? = nil
    public var systemUInt16: StructDefinition { get throws { try lazyInitType(&_systemUInt16, name: "UInt16") } }

    private var _systemInt16: StructDefinition? = nil
    public var systemInt16: StructDefinition { get throws { try lazyInitType(&_systemInt16, name: "Int16") } }

    private var _systemUInt32: StructDefinition? = nil
    public var systemUInt32: StructDefinition { get throws { try lazyInitType(&_systemUInt32, name: "UInt32") } }

    private var _systemInt32: StructDefinition? = nil
    public var systemInt32: StructDefinition { get throws { try lazyInitType(&_systemInt32, name: "Int32") } }

    private var _systemUInt64: StructDefinition? = nil
    public var systemUInt64: StructDefinition { get throws { try lazyInitType(&_systemUInt64, name: "UInt64") } }

    private var _systemInt64: StructDefinition? = nil
    public var systemInt64: StructDefinition { get throws { try lazyInitType(&_systemInt64, name: "Int64") } }

    private var _systemUIntPtr: StructDefinition? = nil
    public var systemUIntPtr: StructDefinition { get throws { try lazyInitType(&_systemUIntPtr, name: "UIntPtr") } }

    private var _systemIntPtr: StructDefinition? = nil
    public var systemIntPtr: StructDefinition { get throws { try lazyInitType(&_systemIntPtr, name: "IntPtr") } }

    private var _systemSingle: StructDefinition? = nil
    public var systemSingle: StructDefinition { get throws { try lazyInitType(&_systemSingle, name: "Single") } }

    private var _systemDouble: StructDefinition? = nil
    public var systemDouble: StructDefinition { get throws { try lazyInitType(&_systemDouble, name: "Double") } }

    private var _systemGuid: StructDefinition? = nil
    public var systemGuid: StructDefinition { get throws { try lazyInitType(&_systemGuid, name: "Guid") } }

    public func getSystemInt(_ size: IntegerSize, signed: Bool) throws -> StructDefinition {
        switch size {
            case .int8: return try signed ? systemSByte : systemByte
            case .int16: return try signed ? systemInt16 : systemUInt16
            case .int32: return try signed ? systemInt32 : systemUInt32
            case .int64: return try signed ? systemInt64 : systemUInt64
            case .intPtr: return try signed ? systemIntPtr : systemUIntPtr
        }
    }

    private func lazyInitType<Definition: TypeDefinition>(_ field: inout Definition?, name: String) throws -> Definition {
        try field.lazyInit {
            try (assembly.resolveTypeDefinition(namespace: "System", name: name) as? Definition)
                .unwrapOrThrow(AssemblyLoadError.notFound(message: "Missing type System.\(name)"))
        }
    }

    internal static func isKnownAssemblyName(_ name: String) -> Bool {
        name == "mscorlib" || name == "System.Runtime"
    }
}