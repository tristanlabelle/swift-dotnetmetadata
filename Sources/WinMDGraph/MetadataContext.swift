import struct Foundation.URL
import WinMD

public typealias AssemblyResolver = (WinMD.AssemblyRef) throws -> Database

public class MetadataContext {
    private let assemblyResolver: AssemblyResolver
    public private(set) var loadedAssemblies: [Assembly] = []
    public private(set) var mscorlib: Mscorlib?

    public init(assemblyResolver: @escaping AssemblyResolver) {
        self.assemblyResolver = assemblyResolver
    }

    public func loadAssembly(url: URL) throws -> Assembly {
        let database = try Database(url: url)
        guard database.tables.assembly.count == 1 else {
            throw WinMD.InvalidFormatError.tableConstraint
        }

        let assemblyRow = database.tables.assembly[0]
        // TODO: de-duplicate against loaded assemblies
        let assemblyImpl = AssemblyFromMetadataImpl(database: database, tableRow: assemblyRow)
        let assembly: Assembly
        if assemblyImpl.name == Mscorlib.name,
            let mscorlib = try? Mscorlib(context: self, impl: assemblyImpl, shadowing: .init()) {

            if self.mscorlib == nil {
                self.mscorlib = mscorlib
            }

            assembly = mscorlib
        }
        else {
            assembly = Assembly(context: self, impl: assemblyImpl)
        }

        loadedAssemblies.append(assembly)
        return assembly
    }
}