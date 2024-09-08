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

    private enum CoreLibraryOrAssemblyReference {
        case coreLibrary(CoreLibrary)
        case assemblyReference(AssemblyReference)
    }

    private let referenceResolver: AssemblyReferenceResolver
    public private(set) var loadedAssembliesByName: [String: Assembly] = [:]
    private var _coreLibraryOrAssemblyReference: CoreLibraryOrAssemblyReference? = nil
    private var uwpTypes = [String: TypeDefinition]()

    /// Initializes a new AssemblyLoadContext, optionally specifying resolving strategies.
    /// - Parameters:
    ///   - referenceResolver: A closure that resolves an assembly reference to a module file.
    public init(
            referenceResolver: AssemblyReferenceResolver? = nil) {
        self.referenceResolver = referenceResolver ?? { identity, _ in
            throw AssemblyLoadError.notFound(message: "Reference to identity \(identity) could not be resolved. No assembly reference resolver was provided.")
        }
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

        if assembly.flags.contains(AssemblyFlags.windowsRuntime), isUWPAssemblyName(assembly.name) {
            // UWP assembly. Store all types by their full name for type reference resolution,
            // since UWP assemblies references are inconsistent and cannot always be resolved.
            for type in assembly.typeDefinitions {
                uwpTypes[type.fullName] = type
            }
        }

        loadedAssembliesByName[assemblyName] = assembly
        return assembly
    }

    internal func resolveType(
            assembly assemblyIdentity: AssemblyIdentity,
            assemblyFlags: AssemblyFlags,
            namespace: String?,
            name: String) throws -> TypeDefinition {
        // References to UWP assemblies can be inconsistent depending on how the WinMD was built:
        // - To contract assemblies, e.g. "Windows.Foundation.UniversalApiContract"
        // - To system metadata assemblies, e.g. "Windows.Foundation"
        // - To partial namespace assemblies, e.g. "Windows.Foundation.Collections"
        // - To union metadata assemblies, e.g. "Windows"
        // Since WinRT does not support overloading by full name and the "Windows." namespace is reserved,
        // we can safely resolve to a previously loaded type by its full name only, ignoring the assembly identity.
        if assemblyFlags.contains(AssemblyFlags.windowsRuntime), isUWPAssemblyName(assemblyIdentity.name),
                let namespace, namespace == "Windows" || namespace.starts(with: "Windows.") {
            let fullName = "\(namespace).\(name)"
            if let typeDefinition = uwpTypes[fullName] { return typeDefinition }
        }

        let assembly = try load(identity: assemblyIdentity, flags: assemblyFlags)
        guard let typeDefinition = try assembly.resolveTypeDefinition(namespace: namespace, name: name) else {
            let fullName = namespace.map { "\($0).\(name)" } ?? name
            throw AssemblyLoadError.notFound(message: "Type '\(fullName)' not found in assembly '\(assembly.name)'")
        }

        return typeDefinition
    }

    private static func isUWPAssemblyName(_ name: String) -> Bool {
        // Assembly name lookup is case-insensitive since it corresponds to files on disk.
        name.compare("Windows", options: .caseInsensitive) == .orderedSame
            || name.compare("Windows.", options: .caseInsensitive) == .orderedSame
    }
}