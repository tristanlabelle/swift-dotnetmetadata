import struct Foundation.UUID

/// A WinRT type signature, used to generate GUIDs for parameterized interface and delegate types.
/// See https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system#guid-generation-for-parameterized-types
public enum WinRTTypeSignature: Hashable {
    case interface(id: UUID, args: [WinRTTypeSignature] = [])
    case delegate(id: UUID, args: [WinRTTypeSignature] = [])
    case baseType(BaseType)
    case comInterface
    indirect case interfaceGroup(name: String, default: WinRTTypeSignature)
    indirect case runtimeClass(name: String, defaultInterface: WinRTTypeSignature)
    case `struct`(name: String, fields: [WinRTTypeSignature])
    case `enum`(name: String, flags: Bool)

    public enum BaseType: String, Hashable {
        case boolean = "b1"
        case uint8 = "u1"
        case int16 = "i2" // Undocumented but presumably valid
        case uint16 = "u2" // Undocumented but presumably valid
        case int32 = "i4"
        case uint32 = "u4"
        case int64 = "i8"
        case uint64 = "u8"
        case single = "f4"
        case double = "f8"
        case char16 = "c2"
        case string = "string"
        case guid = "g16"
    }
}