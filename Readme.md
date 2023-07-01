# DotNetMD

A Swift library for reading and inspecting .NET metadata, including WinMD files, following the [ECMA-335, Common Language Infrastructure (CLI)](https://www.ecma-international.org/publications-and-standards/standards/ecma-335/) standard. Parsing IL is currently out of scope, but not off the table in the future.

![example branch parameter](https://github.com/tristanlabelle/swift-dotnetmd/actions/workflows/build-and-test.yml/badge.svg?branch=main)

## Example

```swift
import DotNetMD

let context = MetadataContext()
let assembly = try context.loadAssembly(path: #"C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.22000.0\Windows.winmd"#)
let typeDefinition = assembly.findDefinedType(fullName: "Windows.Foundation.IClosable")!
print("interface \(typeDefinition.name) {")
for method in typeDefinition.methods {
    print("  void \(method.name)()")
}
print("}")
```

`Package.swift`:

```swift
// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(url: "https://github.com/tristanlabelle/swift-dotnetmd", branch: "main")
    ],
    targets: [
        .executableTarget(name: "MyTarget", dependencies: [
            .product(name: "DotNetMD", package: "swift-dotnetmd")
        ])
    ]
)
```

## Architecture

The library consists in two layered modules:

- `DotNetMD` (logical layer): Provides an object model for .NET concepts of assemblies, types and members, including resolution of cross-assembly references, similar to the `System.Reflection` APIs.
- `DotNetMDFormat` (physical layer): Implements low-level decoding of the .NET portable executable file format and provides a strongly-typed view of the metadata tables, heaps and signatures.

The logical layer can represent a mock `mscorlib` assembly and its core types to support inspecting `.winmd` files, which reference an unresolvable `mscorlib, Version=255.255.255.255`.

### Error Handling

The code currently makes liberal use of `!` and `fatalError`, making it unsuitable for some production scenarios. The plan is to progressively transition to throwing errors as needed, and the expectation is that most of the logical layer API will be marked `throws`, to fail at a fine granularity in the presence of a few pieces of malformed data.
