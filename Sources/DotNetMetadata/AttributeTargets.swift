public struct AttributeTargets: Hashable, OptionSet {
    public var rawValue: Int32

    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }

    public static func | (left: Self, right: Self) -> Self {
        Self(rawValue: left.rawValue | right.rawValue)
    }

    public static func & (left: Self, right: Self) -> Self {
        Self(rawValue: left.rawValue & right.rawValue)
    }

    public static let none = Self([])

    /// Attribute can be applied to an assembly.
    public static let assembly = Self(rawValue: 1)
    /// Attribute can be applied to a module.
    public static let module = Self(rawValue: 2)
    /// Attribute can be applied to a class.
    public static let `class` = Self(rawValue: 4)
    /// Attribute can be applied to a structure; that is, a value type.
    public static let `struct` = Self(rawValue: 8)
    /// Attribute can be applied to an enumeration.
    public static let `enum` = Self(rawValue: 0x10)
    /// Attribute can be applied to a constructor.
    public static let constructor = Self(rawValue: 0x20)
    /// Attribute can be applied to a method.
    public static let method = Self(rawValue: 0x40)
    /// Attribute can be applied to a property.
    public static let property = Self(rawValue: 0x80)
    /// Attribute can be applied to a field.
    public static let field = Self(rawValue: 0x100)
    /// Attribute can be applied to an event.
    public static let event = Self(rawValue: 0x200)
    /// Attribute can be applied to an interface.
    public static let interface = Self(rawValue: 0x400)
    /// Attribute can be applied to a parameter.
    public static let param = Self(rawValue: 0x800)
    /// Attribute can be applied to a delegate.
    public static let delegate = Self(rawValue: 0x1000)
    /// Attribute can be applied to a return value.
    public static let returnValue = Self(rawValue: 0x2000)
    /// Attribute can be applied to a generic parameter.
    public static let genericParam = Self(rawValue: 0x4000)
    /// Attribute can be applied to any application element.
    public static let all = Self(rawValue: 0x7FFF)

    public static let allTypes: Self = .class | .struct | .interface | .enum | .delegate
    public static let allMembers: Self = .field | .method | .property | .event | .constructor
}