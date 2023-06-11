# DotNetMD

A Swift library for reading and inspecting .NET metadata, including `.winmd` files, following the ECMA CLI standard.

## Architecture

The library consists in two layered modules:

- **Physical**: Provides a strongly-typed view of the metadata tables, heaps and signatures in a memory-mapped .NET portable executable file.
- **Logical**: Provides an object model for .NET concepts of assemblies, types and members, including resolution of cross-assembly references, similar to the `System.Reflection` APIs.

The logical layer can represent a mock `mscorlib` assembly and its core types to support inspecting `.winmd` files, which reference an unresolvable `mscorlib, Version=255.255.255.255`.