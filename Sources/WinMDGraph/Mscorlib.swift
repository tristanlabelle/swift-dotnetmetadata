// The mscorlib assembly, exposing definitions for special, core CLI types
public class Mscorlib: Assembly {
    public static let name: String = "mscorlib"

    struct MissingSpecialType: Error {}
    struct Shadowing {}

    init(context: MetadataContext, impl: any AssemblyImpl, shadowing: Shadowing) throws {
        super.init(context: context, impl: impl)
        specialTypes = try SpecialTypes(assembly: self)
    }

    public var specialTypes: SpecialTypes!

    public final class SpecialTypes {
        init(assembly: Assembly) throws {
            func find(_ name: String) throws -> TypeDefinition {
                return try assembly.findTypeDefinition(fullName: "System." + name) ?? { throw MissingSpecialType() }()
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

        public let void: TypeDefinition
        public let object: TypeDefinition
        public let type: TypeDefinition
        public let valueType: TypeDefinition
        public let `enum`: TypeDefinition
        public let delegate: TypeDefinition
        public let multicastDelegate: TypeDefinition
        public let exception: TypeDefinition
        public let attribute: TypeDefinition
        public let string: TypeDefinition
        public let array: TypeDefinition
        public let boolean: TypeDefinition
        public let char: TypeDefinition

        public let byte: TypeDefinition
        public let sbyte: TypeDefinition
        public let uint16: TypeDefinition
        public let int16: TypeDefinition
        public let uint32: TypeDefinition
        public let int32: TypeDefinition
        public let uint64: TypeDefinition
        public let int64: TypeDefinition
        public let uintPtr: TypeDefinition
        public let intPtr: TypeDefinition
        public let single: TypeDefinition
        public let double: TypeDefinition
    }
}