import struct Foundation.URL
import DotNetMD

struct AssemblyNotFound: Error {}
let context = MetadataContext(assemblyResolver: { _ in throw AssemblyNotFound() })
let assembly = try context.loadAssembly(path: #"C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.22000.0\Windows.winmd"#)
let typeDefinition = assembly.findDefinedType(fullName: "Windows.Foundation.IClosable")!
print("interface \(typeDefinition.name) {")
for method in typeDefinition.methods {
    print("  void \(method.name)()")
}
print("}")