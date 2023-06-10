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

    public func loadAssembly(name: String, version: AssemblyVersion, culture: String) throws -> Assembly {
        if name == Mscorlib.name && version == AssemblyVersion.all255 {
            if let mscorlib = self.mscorlib {
                return mscorlib
            }
            else {
                let mscorlib = try Mscorlib(context: self, impl: Mscorlib.MockMscorlibImpl())
                self.mscorlib = mscorlib
                return mscorlib
            }
        }
        else {
            fatalError("Not implemented: assembly resolution")
        }
    }

    public func loadAssembly(url: URL) throws -> Assembly {
        let database = try Database(url: url)
        guard database.tables.assembly.count == 1 else {
            throw WinMD.InvalidFormatError.tableConstraint
        }

        let assemblyRow = database.tables.assembly[0]
        // TODO: de-duplicate against loaded assemblies
        let assemblyImpl = Assembly.MetadataImpl(database: database, tableRow: assemblyRow)
        let assembly: Assembly
        if assemblyImpl.name == Mscorlib.name,
            let mscorlib = try? Mscorlib(context: self, impl: assemblyImpl) {

            if self.mscorlib == nil {
                self.mscorlib = mscorlib
            }

            assembly = mscorlib
        }
        else {
            assembly = try Assembly(context: self, impl: assemblyImpl)
        }

        loadedAssemblies.append(assembly)
        return assembly
    }
}