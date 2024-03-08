
/// Provides access to core types of the System namespace from mscorlib.dll or System.Runtime.dll.
public class CoreLibrary {
    public let assembly: Assembly

    internal init(assembly: Assembly) {
        self.assembly = assembly
    }

    // Fundamental type system types
    private var cachedSystemObject: ClassDefinition? = nil
    public var systemObject: ClassDefinition { get throws { try lazyInitType(&cachedSystemObject, name: "Object") } }

    private var cachedSystemVoid: StructDefinition? = nil
    public var systemVoid: StructDefinition { get throws { try lazyInitType(&cachedSystemVoid, name: "Void") } }

    private var cachedSystemValueType: ClassDefinition? = nil
    public var systemValueType: ClassDefinition { get throws { try lazyInitType(&cachedSystemValueType, name: "ValueType") } }

    private var cachedSystemEnum: ClassDefinition? = nil
    public var systemEnum: ClassDefinition { get throws { try lazyInitType(&cachedSystemEnum, name: "Enum") } }

    private var cachedSystemDelegate: ClassDefinition? = nil
    public var systemDelegate: ClassDefinition { get throws { try lazyInitType(&cachedSystemDelegate, name: "Delegate") } }

    private var cachedSystemMulticastDelegate: ClassDefinition? = nil
    public var systemMulticastDelegate: ClassDefinition { get throws { try lazyInitType(&cachedSystemMulticastDelegate, name: "MulticastDelegate") } }

    private var cachedSystemType: ClassDefinition? = nil
    public var systemType: ClassDefinition { get throws { try lazyInitType(&cachedSystemType, name: "Type") } }

    private var cachedSystemTypedReference: StructDefinition? = nil
    public var systemTypedReference: StructDefinition { get throws { try lazyInitType(&cachedSystemTypedReference, name: "TypedReference") } }

    private var cachedSystemException: ClassDefinition? = nil
    public var systemException: ClassDefinition { get throws { try lazyInitType(&cachedSystemException, name: "Exception") } }

    private var cachedSystemAttribute: ClassDefinition? = nil
    public var systemAttribute: ClassDefinition { get throws { try lazyInitType(&cachedSystemAttribute, name: "Attribute") } }

    private var cachedSystemString: ClassDefinition? = nil
    public var systemString: ClassDefinition { get throws { try lazyInitType(&cachedSystemString, name: "String") } }

    private var cachedSystemArray: ClassDefinition? = nil
    public var systemArray: ClassDefinition { get throws { try lazyInitType(&cachedSystemArray, name: "Array") } }

    // Primitive types
    private var cachedSystemBoolean: StructDefinition? = nil
    public var systemBoolean: StructDefinition { get throws { try lazyInitType(&cachedSystemBoolean, name: "Boolean") } }

    private var cachedSystemChar: StructDefinition? = nil
    public var systemChar: StructDefinition { get throws { try lazyInitType(&cachedSystemChar, name: "Char") } }

    private var cachedSystemByte: StructDefinition? = nil
    public var systemByte: StructDefinition { get throws { try lazyInitType(&cachedSystemByte, name: "Byte") } }

    private var cachedSystemSByte: StructDefinition? = nil
    public var systemSByte: StructDefinition { get throws { try lazyInitType(&cachedSystemSByte, name: "SByte") } }

    private var cachedSystemUInt16: StructDefinition? = nil
    public var systemUInt16: StructDefinition { get throws { try lazyInitType(&cachedSystemUInt16, name: "UInt16") } }

    private var cachedSystemInt16: StructDefinition? = nil
    public var systemInt16: StructDefinition { get throws { try lazyInitType(&cachedSystemInt16, name: "Int16") } }

    private var cachedSystemUInt32: StructDefinition? = nil
    public var systemUInt32: StructDefinition { get throws { try lazyInitType(&cachedSystemUInt32, name: "UInt32") } }

    private var cachedSystemInt32: StructDefinition? = nil
    public var systemInt32: StructDefinition { get throws { try lazyInitType(&cachedSystemInt32, name: "Int32") } }

    private var cachedSystemUInt64: StructDefinition? = nil
    public var systemUInt64: StructDefinition { get throws { try lazyInitType(&cachedSystemUInt64, name: "UInt64") } }

    private var cachedSystemInt64: StructDefinition? = nil
    public var systemInt64: StructDefinition { get throws { try lazyInitType(&cachedSystemInt64, name: "Int64") } }

    private var cachedSystemUIntPtr: StructDefinition? = nil
    public var systemUIntPtr: StructDefinition { get throws { try lazyInitType(&cachedSystemUIntPtr, name: "UIntPtr") } }

    private var cachedSystemIntPtr: StructDefinition? = nil
    public var systemIntPtr: StructDefinition { get throws { try lazyInitType(&cachedSystemIntPtr, name: "IntPtr") } }

    private var cachedSystemSingle: StructDefinition? = nil
    public var systemSingle: StructDefinition { get throws { try lazyInitType(&cachedSystemSingle, name: "Single") } }

    private var cachedSystemDouble: StructDefinition? = nil
    public var systemDouble: StructDefinition { get throws { try lazyInitType(&cachedSystemDouble, name: "Double") } }

    private var cachedSystemGuid: StructDefinition? = nil
    public var systemGuid: StructDefinition { get throws { try lazyInitType(&cachedSystemGuid, name: "Guid") } }

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