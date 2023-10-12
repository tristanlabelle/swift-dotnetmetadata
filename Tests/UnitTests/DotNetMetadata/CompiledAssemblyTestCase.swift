@testable import DotNetMetadata
import XCTest
import Foundation
import WinSDK

internal class CompiledAssemblyTestCase: XCTestCase {
    internal private(set) var assemblyLoadContext: AssemblyLoadContext!
    internal private(set) var assembly: Assembly!

    internal class var csharpCode: String { "" }

    public override func setUpWithError() throws {
        var tempPathChars = [UTF16.CodeUnit](repeating: 0, count: Int(MAX_PATH + 1))
        GetTempPathW(DWORD(tempPathChars.count), &tempPathChars);
        let tempPath = String(decodingCString: tempPathChars, as: UTF16.self)

        let filenameWithoutExtension = UUID().uuidString
        let codeFilePath = "\(tempPath)\\\(filenameWithoutExtension).cs"
        let assemblyFilePath = "\(tempPath)\\\(filenameWithoutExtension).dll"
        try Self.csharpCode.write(toFile: codeFilePath, atomically: true, encoding: .utf8)

        let sdk = try XCTUnwrap(DotNetTool.listSDKs().last)
        let runtime = try XCTUnwrap(DotNetTool.listRuntimes().last { $0.name == "Microsoft.NETCore.App" })
        let refsPath = runtime.refsPath
        let result = try DotNetTool.exec(
            path: sdk.cscPath,
            args: CSharpCompilerArgs(
                nologo: true, nostdlib: true, optimize: false, debug: false, target: .library,
                references: [ "\(refsPath)\\System.Runtime.dll" ],
                output: assemblyFilePath, sources: [codeFilePath]).buildCommandLineArgs())
        guard result.exitCode == 0 else { fatalError() }

        assemblyLoadContext = AssemblyLoadContext()
        assembly = try assemblyLoadContext.load(path: assemblyFilePath)
    }
}