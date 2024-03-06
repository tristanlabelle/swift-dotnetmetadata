import DotNetMetadata
import DotNetMetadataFormat
import Foundation
import XCTest
import WinSDK

/// A class that compiles C# code and loads the resulting assembly.
class CSharpCompilation {
    struct CompilerError: Error, CustomStringConvertible {
        public var message: String

        public var description: String { message }
    }

    public let assemblyLoadContext: AssemblyLoadContext
    public let assembly: Assembly

    public init(code: String) throws {
        var tempPathChars = [UTF16.CodeUnit](repeating: 0, count: Int(MAX_PATH + 1))
        GetTempPathW(DWORD(tempPathChars.count), &tempPathChars);
        var tempPath = String(decodingCString: tempPathChars, as: UTF16.self)
        if tempPath.hasSuffix("\\") { tempPath.removeLast() }

        let filenameWithoutExtension = UUID().uuidString
        let codeFilePath =  "\(tempPath)\\\(filenameWithoutExtension).cs"
        let assemblyFilePath = "\(tempPath)\\\(filenameWithoutExtension).dll"
        try code.write(toFile: codeFilePath, atomically: false, encoding: .utf8)
        defer { try? FileManager.default.removeItem(atPath: codeFilePath) }

        let sdk = try XCTUnwrap(DotNetTool.listSDKs().last)
        let runtime = try XCTUnwrap(DotNetTool.listRuntimes().last { $0.name == "Microsoft.NETCore.App" })
        let refsPath = runtime.refsPath
        let result = try DotNetTool.exec(
            path: sdk.cscPath,
            args: CSharpCompilerArgs(
                nologo: true, nostdlib: true, optimize: false, debug: false, unsafe: true, target: .library,
                references: [ "\(refsPath)\\System.Runtime.dll" ],
                output: assemblyFilePath, sources: [codeFilePath]).buildCommandLineArgs())
        guard result.exitCode == 0 else { throw CompilerError(message: result.standardOutput) }

        // Resolve the core library if tests require it
        assemblyLoadContext = AssemblyLoadContext(resolver: {
            guard $0.name.starts(with: "System.") else { throw AssemblyLoadError.notFound(message: "Unexpected assembly reference.") }
            return try ModuleFile(path: "\(refsPath)\\\($0.name).dll")
        })

        assembly = try assemblyLoadContext.load(path: assemblyFilePath)
    }

    deinit {
        // TODO: Delete dll from temp dir
    }
}