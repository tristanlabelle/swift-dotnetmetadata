// The mscorlib assembly, exposing definitions for special, core CLI types
public final class Mscorlib: Assembly {
    public static let name: String = "mscorlib"

    struct MissingSpecialType: Error {}

    override init(context: MetadataContext, impl: any AssemblyImpl) throws {
        try super.init(context: context, impl: impl)
        specialTypes = try SpecialTypes(assembly: self)
    }

    public var specialTypes: SpecialTypes!

    public final class SpecialTypes {
        init(assembly: Assembly) throws {
            func find<T: TypeDefinition>(_ name: String) throws -> T {
                guard let typeDefinition = assembly.findTypeDefinition(fullName: "System." + name),
                        let typeDefinition = typeDefinition as? T else {
                    throw MissingSpecialType()
                }
                return typeDefinition
            }

            void = try find("Void")
            object = try find("Object")
            type = try find("Type")
            valueType = try find("ValueType")
            `enum` = try find("Enum")
            delegate = try find("Delegate")
            multicastDelegate = try find("MulticastDelegate")
            exception = try find("Exception")
            attribute = try find("Attribute")
            string = try find("String")
            array = try find("Array")

            boolean = try find("Boolean")
            char = try find("Char")
            byte = try find("Byte")
            sbyte = try find("SByte")
            uint16 = try find("UInt16")
            int16 = try find("Int16")
            uint32 = try find("UInt32")
            int32 = try find("Int32")
            uint64 = try find("UInt64")
            int64 = try find("Int64")
            uintPtr = try find("UIntPtr")
            intPtr = try find("IntPtr")
            single = try find("Single")
            double = try find("Double")
        }

        public let void: StructDefinition
        public let object: ClassDefinition
        public let type: ClassDefinition
        public let valueType: ClassDefinition
        public let `enum`: ClassDefinition
        public let delegate: ClassDefinition
        public let multicastDelegate: ClassDefinition
        public let exception: ClassDefinition
        public let attribute: ClassDefinition
        public let string: ClassDefinition
        public let array: ClassDefinition

        public let boolean: StructDefinition
        public let char: StructDefinition
        public let byte: StructDefinition
        public let sbyte: StructDefinition
        public let uint16: StructDefinition
        public let int16: StructDefinition
        public let uint32: StructDefinition
        public let int32: StructDefinition
        public let uint64: StructDefinition
        public let int64: StructDefinition
        public let uintPtr: StructDefinition
        public let intPtr: StructDefinition
        public let single: StructDefinition
        public let double: StructDefinition
    }
}