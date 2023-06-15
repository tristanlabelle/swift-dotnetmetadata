# DotNetMD

A Swift library for reading and inspecting .NET metadata, including WinMD files, following the [ECMA-335, Common Language Infrastructure (CLI)](https://www.ecma-international.org/publications-and-standards/standards/ecma-335/) standard.

## Example

```swift
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
```

## Architecture

The library consists in two layered modules:

- `DotNetMDFormat` (physical layer): Implements low-level decoding of the .NET portable executable file format and provides a strongly-typed view of the metadata tables, heaps and signatures.
- `DotNetMD` (logical layer): Provides an object model for .NET concepts of assemblies, types and members, including resolution of cross-assembly references, similar to the `System.Reflection` APIs.

The logical layer can represent a mock `mscorlib` assembly and its core types to support inspecting `.winmd` files, which reference an unresolvable `mscorlib, Version=255.255.255.255`.

### Error Handling

The code currently makes liberal use of `!` and `fatalError`, making it unsuitable for some production scenarios. The plan is to progressively transition to throwing errors as needed, and the expectation is that most of the Logical API will be marked `throws`, to fail at a fine granularity in the presence of a few pieces of malformed data.