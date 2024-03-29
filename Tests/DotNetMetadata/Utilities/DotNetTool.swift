enum DotNetTool {
    struct Version {
        public var major: UInt
        public var minor: UInt
        public var patch: UInt

        public var string: String { "\(major).\(minor).\(patch)" } 
    }

    struct SDK {
        public var version: Version
        public var path: String

        public var cscPath: String { "\(path)\\Roslyn\\bincore\\csc.dll" }
    }

    struct Runtime {
        public var name: String
        public var version: Version
        public var path: String

        public var refsPath: String {
            // The runtime has a path like dotnet\shared\Microsoft.NETCore.App\#.#.#
            // Reference assemblies are under dotnet\packs\Microsoft.NETCore.App.Ref\#.#.#\ref\net7.0
            var path = self.path.replacingOccurrences(of: "\\shared\\\(name)\\", with: "\\packs\\\(name).Ref\\")
            path += "\\ref\\net\(version.major).\(version.minor)"
            return path
        }
    }

    static func exec(path: String, args: [String]) throws -> Win32Process.Result {
        return try Win32Process.run(application: "dotnet", args: ["exec", path] + args)
    }

    static func listSDKs() throws -> [SDK] {
        let dotnetResult = try Win32Process.run(application: "dotnet", args: ["--list-sdks"])
        guard dotnetResult.exitCode == 0 else { return [] }

        let lineRegex = try Regex(#"^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\s+\[(?<path>[^\]]+)\]\s*?$"#).anchorsMatchLineEndings()
        var searchFrom = dotnetResult.standardOutput.startIndex
        var sdks = [SDK]()
        while let lineMatch = try lineRegex.firstMatch(in: dotnetResult.standardOutput[searchFrom...]) {
            let version = Version(
                major: UInt(lineMatch["major"]!.substring!)!,
                minor: UInt(lineMatch["minor"]!.substring!)!,
                patch: UInt(lineMatch["patch"]!.substring!)!)
            sdks.append(SDK(
                version: version,
                path: lineMatch["path"]!.substring! + "\\" + version.string))
            searchFrom = lineMatch.range.upperBound
        }

        return sdks
    }

    static func listRuntimes() throws -> [Runtime] {
        let dotnetResult = try Win32Process.run(application: "dotnet", args: ["--list-runtimes"])
        guard dotnetResult.exitCode == 0 else { return [] }

        let lineRegex = try Regex(#"^(?<name>[^\s]+)\s+(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\s+\[(?<path>[^\]]+)\]\s*?$"#).anchorsMatchLineEndings()
        var searchFrom = dotnetResult.standardOutput.startIndex
        var runtimes = [Runtime]()
        while let lineMatch = try lineRegex.firstMatch(in: dotnetResult.standardOutput[searchFrom...]) {
            let version = Version(
                major: UInt(lineMatch["major"]!.substring!)!,
                minor: UInt(lineMatch["minor"]!.substring!)!,
                patch: UInt(lineMatch["patch"]!.substring!)!)
            runtimes.append(Runtime(
                name: String(lineMatch["name"]!.substring!),
                version: version,
                path: lineMatch["path"]!.substring! + "\\" + version.string))
            searchFrom = lineMatch.range.upperBound
        }

        return runtimes
    }
}