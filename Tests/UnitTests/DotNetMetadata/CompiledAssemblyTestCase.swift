@testable import DotNetMetadata
import XCTest
import Foundation
import WinSDK

internal class CompiledAssemblyTestCase: XCTestCase {
    struct CompilationFailedError: Error, CustomStringConvertible {
        public var message: String

        public var description: String { message }
    }

    internal class var csharpCode: String { "" }

    private struct Data {
         var assemblyLoadContext: AssemblyLoadContext
         var assembly: Assembly
    }

    private static var data: Result<Data, any Error>!

    internal var assemblyLoadContext: AssemblyLoadContext { try! Self.data.get().assemblyLoadContext }
    internal var assembly: Assembly { try! Self.data.get().assembly }

    public override class func setUp() {
        data = Result {
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
            guard result.exitCode == 0 else { throw CompilationFailedError(message: result.standardOutput) }

            let assemblyLoadContext = AssemblyLoadContext()
            return Data(
                assemblyLoadContext: assemblyLoadContext,
                assembly: try assemblyLoadContext.load(path: assemblyFilePath))
        }
    }

    public override func setUpWithError() throws {
        _ = try XCTUnwrap(Self.data).get()
    }
}