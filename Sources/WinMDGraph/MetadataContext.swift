import struct Foundation.URL
import WinMD

public typealias AssemblyResolver = (WinMD.AssemblyRef) throws -> Database

public class MetadataContext {
    private let assemblyResolver: AssemblyResolver
    private(set) var loadedAssemblies: [Assembly] = []

    public init(assemblyResolver: @escaping AssemblyResolver) {
        self.assemblyResolver = assemblyResolver
    }

    public func loadAssembly(url: URL) throws -> Assembly {
        let database = try Database(url: url)
        guard database.tables.assembly.count == 1 else {
            fatalError("TODO: throw")
        }

        let assemblyRow = database.tables.assembly[0]
        // TODO: de-duplicate against loaded assemblies
        let assembly = Assembly(
            context: self,
            impl: AssemblyFromMetadataImpl(database: database, tableRow: assemblyRow))
        loadedAssemblies.append(assembly)
        return assembly
    }
}