// Identifies a metadata table by the value that identifies it in metadata tokens,
// which is also the order of appearance in the metadata stream.
public enum TableID: UInt8 {
    case module = 0x00
    case typeRef = 0x01
    case typeDef = 0x02
    case field = 0x04
    case methodDef = 0x06
    case param = 0x08
    case interfaceImpl = 0x09
    case memberRef = 0x0A
    case constant = 0x0B
    case customAttribute = 0x0C
    case fieldMarshal = 0x0D
    case declSecurity = 0x0E
    case classLayout = 0x0F
    case fieldLayout = 0x10
    case standAloneSig = 0x11
    case eventMap = 0x12
    case event = 0x14
    case propertyMap = 0x15
    case property = 0x17
    case methodSemantics = 0x18
    case methodImpl = 0x19
    case moduleRef = 0x1A
    case typeSpec = 0x1B
    case implMap = 0x1C
    case fieldRva = 0x1D
    case assembly = 0x20
    case assemblyProcessor = 0x21
    case assemblyOS = 0x22
    case assemblyRef = 0x23
    case assemblyRefProcessor = 0x24
    case assemblyRefOS = 0x25
    case file = 0x26
    case exportedType = 0x27
    case manifestResource = 0x28
    case nestedClass = 0x29
    case genericParam = 0x2A
    case methodSpec = 0x2B
    case genericParamConstraint = 0x2C

    public var intValue: Int { Int(rawValue) }

    public static let count = 64
    public typealias BitSet = UInt64
}