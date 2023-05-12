import struct Foundation.URL
import WinMDGraph

struct AssemblyNotFound: Error {}

let context = MetadataContext(assemblyResolver: { _ in throw AssemblyNotFound() })
let url = URL(fileURLWithPath: #"C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.22000.0\Windows.winmd"#)
let assembly = try context.loadAssembly(url: url)
print("Loaded assembly: \(assembly.name)")
let iclosable = assembly.findTypeDefinition(fullName: "Windows.Foundation.IClosable")!
print("IClosable: \(iclosable.namespace) \(iclosable.name)")