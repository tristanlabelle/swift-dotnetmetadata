extension TypeDefinition {
    public func findMethod(
        name: String,
        public: Bool? = nil,
        static: Bool? = nil,
        genericParamBindings: [TypeNode]? = nil,
        genericArity: Int? = nil,
        arity: Int? = nil,
        paramTypes: [TypeNode]? = nil,
        inherited: Bool = false) -> Method? {

        findMember(
            getter: { $0.methods },
            name: name,
            public: `public`,
            static: `static`,
            genericParamBindings: genericParamBindings,
            predicate: {
                if let genericArity, $0.genericArity != genericArity { return false }
                if let arity, (try? $0.arity) != arity { return false }
                if let paramTypes, !$0.signatureMatches(typeGenericArgs: genericParamBindings, paramTypes: paramTypes) { return false }
                return true
            },
            inherited: inherited)
    }

    public func findConstructor(
        public: Bool? = nil,
        genericParamBindings: [TypeNode]? = nil,
        arity: Int? = nil,
        paramTypes: [TypeNode]? = nil,
        inherited: Bool = false) -> Constructor? {

        findMethod(
            name: Constructor.name,
            public: `public`,
            genericParamBindings: genericParamBindings,
            arity: arity,
            paramTypes: paramTypes,
            inherited: inherited) as? Constructor
    }

    public func findField(
        name: String, 
        public: Bool? = nil,
        static: Bool? = nil,
        inherited: Bool = false) -> Field? {

        findMember(
            getter: { $0.fields },
            name: name,
            public: `public`,
            static: `static`,
            inherited: inherited)
    }

    public func findProperty(
        name: String,
        public: Bool? = nil,
        static: Bool? = nil,
        inherited: Bool = false) -> Property? {

        findMember(
            getter: { $0.properties },
            name: name,
            public: `public`,
            static: `static`,
            inherited: inherited)
    }

    public func findEvent(
        name: String,
        public: Bool? = nil,
        static: Bool? = nil,
        inherited: Bool = false) -> Event? {

        findMember(
            getter: { $0.events },
            name: name,
            public: `public`,
            static: `static`,
            inherited: inherited)
    }

    private func findMember<M: Member>(
        getter: (TypeDefinition) -> [M],
        name: String,
        public: Bool? = nil,
        static: Bool? = nil,
        genericParamBindings: [TypeNode]? = nil,
        predicate: ((M) -> Bool)? = nil,
        inherited: Bool = false) -> M? {

        var result: M? = nil
        gatherMembers(
            getter: getter,
            name: name,
            public: `public`,
            static: `static`,
            genericParamBindings: genericParamBindings,
            predicate: predicate,
            inherited: inherited) {
                if result == nil {
                    result = $0
                    return true
                }
                else {
                    // Disallow multiple matches
                    result = nil
                    return false
                }
            }

        return result
    }

    private func gatherMembers<M: Member>(
        getter: (TypeDefinition) -> [M],
        name: String? = nil,
        public: Bool? = nil,
        static: Bool? = nil,
        genericParamBindings: [TypeNode]? = nil,
        predicate: ((M) -> Bool)? = nil,
        inherited: Bool = false,
        action: (M) -> Bool) {

        if let genericParamBindings, genericParamBindings.count != genericArity {
            precondition(false, "Generic bindings must match type generic arity")
            return
        }

        var typeDefinition = self
        var genericParamBindings = genericParamBindings
        while true {
            for member in getter(typeDefinition) {
                if let name, member.name != name { continue }
                if let `public`, (member.visibility == .public) != `public` { continue }
                if let `static`, member.isStatic != `static` { continue }
                if let predicate, !predicate(member) { continue }
                guard action(member) else { return }
            }

            guard inherited, let base = try? typeDefinition.base else { return }

            genericParamBindings = genericParamBindings == nil ? base.genericArgs : base.genericArgs.map {
                $0.bindGenericParams(typeArgs: genericParamBindings, methodArgs: nil)
            }
            typeDefinition = base.definition
        }
    }
}