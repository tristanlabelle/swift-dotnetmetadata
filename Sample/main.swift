import struct Foundation.URL
import DotNetMDPhysical
import DotNetMDLogical

struct AssemblyNotFound: Error {}

let url = URL(fileURLWithPath: #"C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.22000.0\Windows.DotNetMDPhysical"#)

let database = try Database(url: url)
let assemblyRef = database.tables.assemblyRef[0]
let name = database.heaps.resolve(database.tables.assemblyRef[0].name)
print("\(name) \(assemblyRef.majorVersion).\(assemblyRef.minorVersion).\(assemblyRef.buildNumber).\(assemblyRef.revisionNumber)")

// let context = MetadataContext(assemblyResolver: { _ in throw AssemblyNotFound() })
// let assembly = try context.loadAssembly(url: url)
// print("Loaded assembly: \(assembly.name)")
// let iclosable = assembly.findTypeDefinition(fullName: "Windows.Foundation.IClosable")!
// print("interface IClosable {")
// for method in iclosable.methods {
//     print("  void \(method.name)")
// }
// print("}")