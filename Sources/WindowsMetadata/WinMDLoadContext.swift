import DotNetMetadata
import DotNetMetadataFormat

/// An assembly load context for Windows Metadata files,
/// with special handling for Universal Windows Platform (UWP) assemblies.
public class WinMDLoadContext: AssemblyLoadContext {
    // References to UWP assemblies can be inconsistent depending on how the WinMD was built:
    // - To contract assemblies, e.g. "Windows.Foundation.UniversalApiContract"
    // - To system metadata assemblies, e.g. "Windows.Foundation"
    // - To partial namespace assemblies, e.g. "Windows.Foundation.Collections" (no such file exists)
    // - To union metadata assemblies, e.g. "Windows"
    //
    // This is a problem when we load "Windows.Foundation.UniversalApiContract" and then encounter
    // a WinMD file that references "Windows", or the other way around, and loading both would be redundant.
    // To avoid this, we rely on the fact that "Windows." is reserved for UWP assemblies,
    // and we bypass assembly resolution to directly resolve UWP types by name.

    private var uwpTypes = [String: TypeDefinition]()

    public func findUWPType(name: TypeName) -> TypeDefinition? {
        uwpTypes[name.fullName]
    }

    public override func _willLoad(name: String, flags: AssemblyFlags) throws {
        guard name == "mscorlib" || flags.contains(AssemblyFlags.windowsRuntime) else {
            throw AssemblyLoadError.invalid(message: "'\(name)' is not a valid Windows Metadata assembly")
        }
        try super._willLoad(name: name, flags: flags)
    }

    public override func _didLoad(_ assembly: Assembly) {
        if assembly.flags.contains(AssemblyFlags.windowsRuntime), Self.isUWPAssembly(name: assembly.name) {
            // UWP assembly. Store all types by their full name for type reference resolution,
            // since UWP assemblies references are inconsistent and cannot always be resolved.
            for type in assembly.typeDefinitions {
                guard type.namespace?.starts(with: "Windows.") != false else { continue }
                uwpTypes[type.fullName] = type
            }
        }

        super._didLoad(assembly)
    }

    public override func resolveType(assembly assemblyIdentity: AssemblyIdentity, assemblyFlags: AssemblyFlags?, name: TypeName) throws -> TypeDefinition {
        if assemblyFlags?.contains(AssemblyFlags.windowsRuntime) != false, Self.isUWPAssembly(name: assemblyIdentity.name),
                let namespace = name.namespace, namespace == "Windows" || namespace.starts(with: "Windows.") {
            if let typeDefinition = uwpTypes[name.fullName] { return typeDefinition }
        }

        return try super.resolveType(assembly: assemblyIdentity, assemblyFlags: assemblyFlags, name: name)
    }

    /// Determines whether a given assembly name is reserved for the Universal Windows Platform.
    public static func isUWPAssembly(name: String) -> Bool {
        // From https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system :
        // > Types provided by Windows are all contained under the Windows.* namespace.
        // > WinRT types that are not provided by Windows (including WinRT types that are provided
        // > by other parts of Microsoft) must live in a namespace other than Windows.*.

        // UWP references are inconsistent and do not always match the expected case.
        let lowercasedName = name.lowercased()
        return lowercasedName == "windows" || lowercasedName.starts(with: "windows.")
    }
}