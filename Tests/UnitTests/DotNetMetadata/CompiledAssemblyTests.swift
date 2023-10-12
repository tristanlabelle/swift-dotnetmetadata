@testable import DotNetMetadata
import XCTest
import Foundation
import WinSDK

final class CompiledAssemblyTests: XCTestCase {
    private var assemblyLoadContext: AssemblyLoadContext!

    public override func setUpWithError() throws {
        assemblyLoadContext = AssemblyLoadContext()
    }

    private func compileToAssembly(code: String) throws -> Assembly {
        var tempPathChars = [UTF16.CodeUnit](repeating: 0, count: Int(MAX_PATH + 1))
        GetTempPathW(DWORD(tempPathChars.count), &tempPathChars);
        let tempPath = String(decodingCString: tempPathChars, as: UTF16.self)

        let filenameWithoutExtension = UUID().uuidString
        let codeFilePath = "\(tempPath)\\\(filenameWithoutExtension).cs"
        let assemblyFilePath = "\(tempPath)\\\(filenameWithoutExtension).dll"
        try code.write(toFile: codeFilePath, atomically: true, encoding: .utf8)

        let sdk = try DotNetTool.listSDKs().last!
        let runtime = try DotNetTool.listRuntimes().last { $0.name == "Microsoft.NETCore.App" }!
        let result = try DotNetTool.runApp(
            path: DotNetTool.getCscPath(sdkPath: sdk.path),
            args: CSharpCompilerArgs(
                noLogo: true, optimize: false, debug: false, target: .library,
                references: [ "\(runtime.path)\\System.Private.CoreLib.dll" ],
                output: assemblyFilePath, sources: [codeFilePath]).buildCommandLineArgs())
        guard result.exitCode == 0 else { fatalError() }

        return try assemblyLoadContext.load(path: assemblyFilePath)
    }

    private func assertNotNil<T>(_ value: T?) -> T? {
        XCTAssertNotNil(value)
        return value
    }

    public func testFields() throws {
        let assembly = try compileToAssembly(code: """
            public class Fields {
                public int PublicInstance;
                private static readonly int PrivateStaticInitOnly;
            }
            """)

        let typeDefinition = try XCTUnwrap(assembly.findDefinedType(fullName: "Fields"))

        XCTAssertEqual(
            typeDefinition.fields.map { $0.name },
            ["PublicInstance", "PrivateStaticInitOnly"])

        if let publicInstanceField = assertNotNil(typeDefinition.findField(name: "PublicInstance")) {
            XCTAssertEqual(publicInstanceField.visibility, .public)
            XCTAssertEqual(publicInstanceField.isStatic, false)
            XCTAssertEqual(publicInstanceField.isInitOnly, false)
        }

        if let privateStaticInitOnlyField = assertNotNil(typeDefinition.findField(name: "PrivateStaticInitOnly")) {
            XCTAssertEqual(privateStaticInitOnlyField.visibility, .private)
            XCTAssertEqual(privateStaticInitOnlyField.isStatic, true)
            XCTAssertEqual(privateStaticInitOnlyField.isInitOnly, true)
        }
    }
}