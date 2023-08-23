import struct Foundation.URL
import DotNetMetadataFormat

public enum AssemblyLoadError: Error {
    case notFound(message: String? = nil)
    case invalid(message: String? = nil, inner: (any Error)? = nil)
}

public typealias AssemblyResolver = (AssemblyIdentity) throws -> ModuleFile

public final class AssemblyLoadContext {
    private let resolver: AssemblyResolver
    public private(set) var loadedAssembliesByName: [String: Assembly] = [:]

    public init(resolver: @escaping AssemblyResolver) {
        self.resolver = resolver
    }

    public convenience init() {
        self.init(resolver: { _ in
            throw AssemblyLoadError.notFound(message: "No assembly resolver was provided")
        })
    }

    public var mscorlib: Mscorlib? { loadedAssembliesByName[Mscorlib.name] as? Mscorlib }

    public func load(identity: AssemblyIdentity) throws -> Assembly {
        if let assembly = loadedAssembliesByName[identity.name] {
            // TODO: Check if identities match
            return assembly
        }

        return try load(moduleFile: try resolver(identity))
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

        let assemblyRow = moduleFile.assemblyTable[0]
        let assemblyName = moduleFile.resolve(assemblyRow.name)
        if loadedAssembliesByName[assemblyName] != nil {
            throw AssemblyLoadError.invalid(message: "Assembly with name '\(assemblyName)' already loaded")
        }

        let assembly: Assembly = assemblyName == Mscorlib.name
            ? try Mscorlib(context: self, moduleFile: moduleFile, tableRow: assemblyRow)
            : try Assembly(context: self, moduleFile: moduleFile, tableRow: assemblyRow)

        loadedAssembliesByName[assemblyName] = assembly
        return assembly
    }
}