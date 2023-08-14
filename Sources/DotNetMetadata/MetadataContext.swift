import struct Foundation.URL
import DotNetMetadataFormat

public typealias AssemblyResolver = (AssemblyIdentity) throws -> ModuleFile

public class MetadataContext {
    private let assemblyResolver: AssemblyResolver
    public private(set) var loadedAssemblies: [Assembly] = []
    public private(set) var mscorlib: Mscorlib?

    public init(assemblyResolver: @escaping AssemblyResolver) {
        self.assemblyResolver = assemblyResolver
    }

    public convenience init() {
        struct AssemblyNotFound: Error {}
        self.init(assemblyResolver: { _ in throw AssemblyNotFound() })
    }

    public func loadAssembly(identity: AssemblyIdentity) throws -> Assembly {
        for assembly in loadedAssemblies {
            if assembly.name == identity.name {
                return assembly
            }
        }

        return try loadAssembly(moduleFile: try assemblyResolver(identity))
    }

    public func loadAssembly(url: URL) throws -> Assembly {
        return try loadAssembly(moduleFile: try ModuleFile(url: url))
    }

    private func loadAssembly(moduleFile: ModuleFile) throws -> Assembly {
        guard moduleFile.assemblyTable.count == 1 else {
            throw DotNetMetadataFormat.InvalidFormatError.tableConstraint
        }

        let assemblyRow = moduleFile.assemblyTable[0]
        let assembly: Assembly
        if mscorlib == nil, moduleFile.resolve(assemblyRow.name) == Mscorlib.name {
            self.mscorlib = try? Mscorlib(context: self, moduleFile: moduleFile, tableRow: assemblyRow)
            assembly = try self.mscorlib ?? Assembly(context: self, moduleFile: moduleFile, tableRow: assemblyRow)
        }
        else {
            assembly = try Assembly(context: self, moduleFile: moduleFile, tableRow: assemblyRow)
        }

        loadedAssemblies.append(assembly)
        return assembly
    }

    public func loadAssembly(path: String) throws -> Assembly {
        try loadAssembly(url: URL(fileURLWithPath: path))
    }
}