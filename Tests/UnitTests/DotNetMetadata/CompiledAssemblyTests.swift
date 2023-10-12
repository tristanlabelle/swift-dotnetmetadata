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
                protected const int ProtectedLiteral = 42;
            }
            """)

        let typeDefinition = try XCTUnwrap(assembly.findDefinedType(fullName: "Fields"))

        XCTAssertEqual(
            typeDefinition.fields.map { $0.name },
            ["PublicInstance", "PrivateStaticInitOnly", "ProtectedLiteral"])

        if let publicInstanceField = assertNotNil(typeDefinition.findField(name: "PublicInstance")) {
            XCTAssertEqual(publicInstanceField.name, "PublicInstance")
            XCTAssertEqual(publicInstanceField.visibility, .public)
            XCTAssertEqual(publicInstanceField.isStatic, false)
            XCTAssertEqual(publicInstanceField.isInitOnly, false)
            XCTAssertEqual(publicInstanceField.isLiteral, false)
            XCTAssertEqual(try publicInstanceField.literalValue, nil)
        }

        if let privateStaticInitOnlyField = assertNotNil(typeDefinition.findField(name: "PrivateStaticInitOnly")) {
            XCTAssertEqual(privateStaticInitOnlyField.name, "PrivateStaticInitOnly")
            XCTAssertEqual(privateStaticInitOnlyField.visibility, .private)
            XCTAssertEqual(privateStaticInitOnlyField.isStatic, true)
            XCTAssertEqual(privateStaticInitOnlyField.isInitOnly, true)
            XCTAssertEqual(privateStaticInitOnlyField.isLiteral, false)
            XCTAssertEqual(try privateStaticInitOnlyField.literalValue, nil)
        }

        if let protectedLiteralField = assertNotNil(typeDefinition.findField(name: "ProtectedLiteral")) {
            XCTAssertEqual(protectedLiteralField.name, "ProtectedLiteral")
            XCTAssertEqual(protectedLiteralField.visibility, .family)
            XCTAssertEqual(protectedLiteralField.isStatic, true)
            XCTAssertEqual(protectedLiteralField.isInitOnly, false)
            XCTAssertEqual(protectedLiteralField.isLiteral, true)
            XCTAssertEqual(try protectedLiteralField.literalValue, Constant.int32(42))
        }
    }
}