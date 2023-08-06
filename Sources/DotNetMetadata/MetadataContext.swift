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
        if identity.name == Mscorlib.name && identity.version == AssemblyVersion.all255 {
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
        let moduleFile = try ModuleFile(url: url)
        guard moduleFile.assemblyTable.count == 1 else {
            throw DotNetMetadataFormat.InvalidFormatError.tableConstraint
        }

        let assemblyRow = moduleFile.assemblyTable[0]
        // TODO: de-duplicate against loaded assemblies
        let assemblyImpl = Assembly.MetadataImpl(moduleFile: moduleFile, tableRow: assemblyRow)
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

    public func loadAssembly(path: String) throws -> Assembly {
        try loadAssembly(url: URL(fileURLWithPath: path))
    }
}