import struct Foundation.URL
import DotNetMetadataFormat

public enum AssemblyLoadError: Error {
    case notFound(message: String? = nil)
    case invalid(message: String? = nil, inner: (any Error)? = nil)
}

/// A context in which assemblies are loaded and their references can be resolved
/// to allow building a .NET type graph spanning types from multiple assemblies.
/// This is analoguous to the System.AppDomain class in the .NET Framework.
///
/// This class manages the lifetime of its object graph.
public final class AssemblyLoadContext {
    /// A closure that resolves an assembly reference to a module file.
    public typealias AssemblyReferenceResolver = (AssemblyIdentity, AssemblyFlags?) throws -> ModuleFile

    /// A reference to a type in another assembly.
    public struct TypeReference {
        public let assembly: AssemblyIdentity
        public let assemblyFlags: AssemblyFlags?
        public let namespace: String?
        public let name: String

        public var fullName: String { namespace.map { "\($0).\(name)" } ?? name }
        public init(assembly: AssemblyIdentity, assemblyFlags: AssemblyFlags? = nil, namespace: String?, name: String) {
            self.assembly = assembly
            self.assemblyFlags = assemblyFlags
            self.namespace = namespace
            self.name = name
        }
    }

    /// A closure that resolves a type reference to a type definition.
    public typealias TypeReferenceResolver = (AssemblyLoadContext, TypeReference) throws -> TypeDefinition?

    private enum CoreLibraryOrAssemblyReference {
        case coreLibrary(CoreLibrary)
        case assemblyReference(AssemblyReference)
    }

    private let referenceResolver: AssemblyReferenceResolver
    private let typeReferenceResolver: TypeReferenceResolver?
    public private(set) var loadedAssembliesByName: [String: Assembly] = [:]
    private var _coreLibraryOrAssemblyReference: CoreLibraryOrAssemblyReference? = nil

    /// Initializes a new AssemblyLoadContext, optionally specifying resolving strategies.
    /// - Parameters:
    ///   - referenceResolver: A closure that resolves an assembly reference to a module file.
    ///   - typeReferenceResolver: A closure that resolves a type reference to a type definition, possibly bypassing assembly reference resolution.
    public init(
            referenceResolver: AssemblyReferenceResolver? = nil,
            typeReferenceResolver: TypeReferenceResolver? = nil) {
        self.referenceResolver = referenceResolver ?? { identity, _ in
            throw AssemblyLoadError.notFound(message: "Reference to identity \(identity) could not be resolved. No assembly reference resolver was provided.")
        }
        self.typeReferenceResolver = typeReferenceResolver
    }

    deinit {
        // Our data model is inherently prone to reference cycles,
        // for example with a linked list node type definition with a field referencing itself.
        // To avoid memory leaks, break reference cycles.
        // This means nulling out every cached reference that is not strictly owned by the parent.
        for assembly in loadedAssembliesByName.values {
            assembly.breakReferenceCycles()
        }
    }

    public var coreLibrary: CoreLibrary {
        get throws {
            guard let coreLibraryOrAssemblyReference = _coreLibraryOrAssemblyReference else {
                throw AssemblyLoadError.notFound(message: "No core library assembly loaded or referenced.")
            }

            switch coreLibraryOrAssemblyReference {
                case .coreLibrary(let coreLibrary): return coreLibrary

                // Lazy load and create the CoreLibrary instance
                case .assemblyReference(let reference):
                    let assembly = try load(identity: reference.identity)
                    let coreLibrary = CoreLibrary(assembly: assembly)
                    _coreLibraryOrAssemblyReference = .coreLibrary(coreLibrary)
                    return coreLibrary
            }
        }
    }

    public func load(identity: AssemblyIdentity, flags: AssemblyFlags? = nil) throws -> Assembly {
        if let assembly = loadedAssembliesByName[identity.name] {
            return assembly
        }

        return try load(moduleFile: try referenceResolver(identity, flags))
    }

    public func load(url: URL) throws -> Assembly {
        return try load(moduleFile: try ModuleFile(url: url))
    }

    public func load(path: String) throws -> Assembly {
        try load(url: URL(fileURLWithPath: path))
    }

    private func load(moduleFile: ModuleFile) throws -> Assembly {
        guard moduleFile.assemblyTable.count == 1 else {
            throw DotNetMetadataFormat.InvalidFormatError.tableConstraint
        }

        let assemblyRow = moduleFile.assemblyTable.first!
        let assemblyName = moduleFile.resolve(assemblyRow.name)
        if loadedAssembliesByName[assemblyName] != nil {
            throw AssemblyLoadError.invalid(message: "Assembly with name '\(assemblyName)' already loaded")
        }

        let assembly: Assembly = try Assembly(context: self, moduleFile: moduleFile, tableRow: assemblyRow)
        if _coreLibraryOrAssemblyReference == nil {
            if CoreLibrary.isKnownAssemblyName(assembly.name) {
                _coreLibraryOrAssemblyReference = .coreLibrary(CoreLibrary(assembly: assembly))
            }
            else {
                for reference in assembly.references {
                    if CoreLibrary.isKnownAssemblyName(reference.name) {
                        _coreLibraryOrAssemblyReference = .assemblyReference(reference)
                        break
                    }
                }
            }
        }

        loadedAssembliesByName[assemblyName] = assembly
        return assembly
    }

    public func resolve(_ typeReference: TypeReference) throws -> TypeDefinition {
        if let typeReferenceResolver, let typeDefinition = try typeReferenceResolver(self, typeReference) { return typeDefinition }

        let assembly = try load(identity: typeReference.assembly, flags: typeReference.assemblyFlags)
        guard let typeDefinition = try assembly.resolveTypeDefinition(namespace: typeReference.namespace, name: typeReference.name) else {
            throw AssemblyLoadError.notFound(message: "Type '\(typeReference.fullName)' not found in assembly '\(assembly.name)'")
        }

        return typeDefinition
    }
}