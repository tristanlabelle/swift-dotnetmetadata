import struct Foundation.URL
import DotNetMDLogical

struct AssemblyNotFound: Error {}

let url = URL(fileURLWithPath: #"C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.22000.0\Windows.winmd"#)

let context = MetadataContext(assemblyResolver: { _ in throw AssemblyNotFound() })
let assembly = try context.loadAssembly(url: url)
let iclosable = assembly.findTypeDefinition(fullName: "Windows.Foundation.IClosable")!
print("interface IClosable {")
for method in iclosable.methods {
    print("  void \(method.name)()")
}
print("}")