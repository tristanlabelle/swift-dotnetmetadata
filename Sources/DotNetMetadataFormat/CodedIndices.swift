public enum CodedIndices {
    public typealias CustomAttributeType = CodedIndex<Tags.CustomAttributeType>
    public typealias HasConstant = CodedIndex<Tags.HasConstant>
    public typealias HasDeclSecurity = CodedIndex<Tags.HasDeclSecurity>
    public typealias HasFieldMarshal = CodedIndex<Tags.HasFieldMarshal>
    public typealias HasSemantics = CodedIndex<Tags.HasSemantics>
    public typealias HasCustomAttribute = CodedIndex<Tags.HasCustomAttribute>
    public typealias Implementation = CodedIndex<Tags.Implementation>
    public typealias MemberForwarded = CodedIndex<Tags.MemberForwarded>
    public typealias MemberRefParent = CodedIndex<Tags.MemberRefParent>
    public typealias MethodDefOrRef = CodedIndex<Tags.MethodDefOrRef>
    public typealias ResolutionScope = CodedIndex<Tags.ResolutionScope>
    public typealias TypeDefOrRef = CodedIndex<Tags.TypeDefOrRef>
    public typealias TypeOrMethodDef = CodedIndex<Tags.TypeOrMethodDef>

    public enum Tags {
        public enum CustomAttributeType: UInt8, CodedIndexTag {
            case methodDef = 2
            case memberRef = 3

            public init(value: UInt8) throws {
                switch value {
                    case 2: self = .methodDef
                    case 3: self = .memberRef
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ nil, nil, .methodDef, .memberRef, nil ]
        }

        public enum HasConstant: UInt8, CodedIndexTag {
            case field = 0
            case param = 1
            case property = 2

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .field
                    case 1: self = .param
                    case 2: self = .property
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .field, .param, .property ]
        }

        public enum HasDeclSecurity: UInt8, CodedIndexTag {
            case typeDef = 0
            case methodDef = 1
            case assembly = 2

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .typeDef
                    case 1: self = .methodDef
                    case 2: self = .assembly
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .typeDef, .methodDef, .assembly ]
        }

        public enum HasFieldMarshal: UInt8, CodedIndexTag {
            case field = 0
            case param = 1

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .field
                    case 1: self = .param
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .field, .param ]
        }

        public enum HasSemantics: UInt8, CodedIndexTag {
            case event = 0
            case property = 1

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .event
                    case 1: self = .property
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .event, .property ]
        }

        public enum HasCustomAttribute: UInt8, CodedIndexTag {
            case methodDef = 0
            case field = 1
            case typeRef = 2
            case typeDef = 3
            case param = 4
            case interfaceImpl = 5
            case memberRef = 6
            case module = 7
            case declSecurity = 8
            case property = 9
            case event = 10
            case standAloneSig = 11
            case moduleRef = 12
            case typeSpec = 13
            case assembly = 14
            case assemblyRef = 15
            case file = 16
            case exportedType = 17
            case manifestResource = 18
            case genericParam = 19
            case genericParamConstraint = 20
            case methodSpec = 21

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .methodDef
                    case 1: self = .field
                    case 2: self = .typeRef
                    case 3: self = .typeDef
                    case 4: self = .param
                    case 5: self = .interfaceImpl
                    case 6: self = .memberRef
                    case 7: self = .module
                    case 8: self = .declSecurity
                    case 9: self = .property
                    case 10: self = .event
                    case 11: self = .standAloneSig
                    case 12: self = .moduleRef
                    case 13: self = .typeSpec
                    case 14: self = .assembly
                    case 15: self = .assemblyRef
                    case 16: self = .file
                    case 17: self = .exportedType
                    case 18: self = .manifestResource
                    case 19: self = .genericParam
                    case 20: self = .genericParamConstraint
                    case 21: self = .methodSpec
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [
                .methodDef, .field, .typeRef, .typeDef, .param, .interfaceImpl,
                .memberRef, .module, .declSecurity, .property, .event, .standAloneSig,
                .moduleRef, .typeSpec, .assembly, .assemblyRef, .file, .exportedType,
                .manifestResource, .genericParam, .genericParamConstraint, .methodSpec
            ]
        }

        public enum Implementation: UInt8, CodedIndexTag {
            case file = 0
            case assemblyRef = 1
            case exportedType = 2

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .file
                    case 1: self = .assemblyRef
                    case 2: self = .exportedType
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .file, .assemblyRef, .exportedType ]
        }

        public enum MemberForwarded: UInt8, CodedIndexTag {
            case field = 0
            case methodDef = 1

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .field
                    case 1: self = .methodDef
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .field, .methodDef ]
        }

        public enum MemberRefParent: UInt8, CodedIndexTag {
            case typeDef = 0
            case typeRef = 1
            case moduleRef = 2
            case methodDef = 3
            case typeSpec = 4

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .typeDef
                    case 1: self = .typeRef
                    case 2: self = .moduleRef
                    case 3: self = .methodDef
                    case 4: self = .typeSpec
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .typeDef, .typeRef, .moduleRef, .methodDef, .typeSpec ]
        }

        public enum MethodDefOrRef: UInt8, CodedIndexTag {
            case methodDef = 0
            case memberRef = 1

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .methodDef
                    case 1: self = .memberRef
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .methodDef, .memberRef ]
        }

        public enum ResolutionScope: UInt8, CodedIndexTag {
            case module = 0
            case moduleRef = 1
            case assemblyRef = 2
            case typeRef = 3

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .module
                    case 1: self = .moduleRef
                    case 2: self = .assemblyRef
                    case 3: self = .typeRef
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .module, .moduleRef, .assemblyRef, .typeRef ]
        }

        public enum TypeDefOrRef: UInt8, CodedIndexTag {
            case typeDef = 0
            case typeRef = 1
            case typeSpec = 2

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .typeDef
                    case 1: self = .typeRef
                    case 2: self = .typeSpec
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .typeDef, .typeRef, .typeSpec ]
        }

        public enum TypeOrMethodDef: UInt8, CodedIndexTag {
            case typeDef = 0
            case methodDef = 1

            public init(value: UInt8) throws {
                switch value {
                    case 0: self = .typeDef
                    case 1: self = .methodDef
                    default: throw InvalidFormatError.tableConstraint
                }
            }

            public static let tables: [TableID?] = [ .typeDef, .methodDef ]
        }
    }
}