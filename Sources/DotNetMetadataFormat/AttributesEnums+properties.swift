extension EventAttributes {
    public var nameKind: NameKind {
        if self.contains(.rtSpecialName) { return .runtime }
        else if self.contains(.specialName) { return .special }
        else { return .regular }
    }
}

extension FieldAttributes {
    public var nameKind: NameKind {
        if self.contains(.rtSpecialName) { return .runtime }
        else if self.contains(.specialName) { return .special }
        else { return .regular }
    }

    public var visibility: Visibility {
        switch self.intersection(.fieldAccessMask) {
            case .compilerControlled: return .compilerControlled
            case .private: return .private
            case .assembly: return .assembly
            case .famANDAssem: return .familyAndAssembly
            case .famORAssem: return .familyOrAssembly
            case .family: return .family
            case .public: return .public
            default: fatalError()
        }
    }
}

extension MethodAttributes {
    public var nameKind: NameKind {
        if self.contains(.rtSpecialName) { return .runtime }
        else if self.contains(.specialName) { return .special }
        else { return .regular }
    }

    public var visibility: Visibility {
        switch self.intersection(.memberAccessMask) {
            case .compilerControlled: return .compilerControlled
            case .private: return .private
            case .assem: return .assembly
            case .famANDAssem: return .familyAndAssembly
            case .famORAssem: return .familyOrAssembly
            case .family: return .family
            case .public: return .public
            default: fatalError()
        }
    }
}

extension PropertyAttributes {
    public var nameKind: NameKind {
        if self.contains(.rtSpecialName) { return .runtime }
        else if self.contains(.specialName) { return .special }
        else { return .regular }
    }
}

extension TypeAttributes {
    public var nameKind: NameKind {
        if self.contains(.rtSpecialName) { return .runtime }
        else if self.contains(.specialName) { return .special }
        else { return .regular }
    }

    public var visibility: Visibility {
        switch self.intersection(.visibilityMask) {
            case .public, .nestedPublic: return .public
            case .notPublic, .nestedAssembly: return .assembly
            case .nestedFamily: return .family
            case .nestedFamORAssem: return .familyOrAssembly
            case .nestedFamANDAssem: return .familyAndAssembly
            case .nestedPrivate: return .private
            default: fatalError()
        }
    }

    public var isNested: Bool {
        switch self.intersection(.visibilityMask) {
            case .public, .notPublic: return false
            case .nestedPublic, .nestedFamily,
                .nestedFamORAssem, .nestedFamANDAssem,
                .nestedAssembly, .nestedPrivate: return true
            default: fatalError()
        }
    }

    public var layoutKind: LayoutKind {
        switch self.intersection(.layoutMask) {
            case .autoLayout: return .auto
            case .sequentialLayout: return .sequential
            case .explicitLayout: return .explicit
            default: fatalError()
        }
    }
}