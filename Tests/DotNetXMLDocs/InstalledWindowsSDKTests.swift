@testable import DotNetXMLDocs
import XCTest
import Foundation
import FoundationXML

final class InstalledWindowsSDKTests: XCTestCase {
    func testParseWindowsUniversalApiContract() throws {
        let programFilesX86Path = ProcessInfo.processInfo.environment["ProgramFiles(x86)"]
            ?? ((ProcessInfo.processInfo.environment["SystemDrive"] ?? "C:") + "\\Program Files (x86)")
        let windowsKits10Path = programFilesX86Path + "\\Windows Kits\\10"
        guard let referencesPath = Self.firstSubdirectory(parent: windowsKits10Path + "\\References"),
                let universalAPIContractPath = Self.firstSubdirectory(parent: referencesPath + "\\Windows.Foundation.UniversalApiContract"),
                let xmlString = try? String(contentsOf: URL(fileURLWithPath: universalAPIContractPath + "\\en\\Windows.Foundation.UniversalApiContract.xml")),
                let xmlDocument = try? XMLDocument(xmlString: xmlString) else {
            throw XCTSkip("Could not find an installed Windows SDK with Windows.Foundation.UniversalApiContract.xml")
        }

        _ = try AssemblyDocumentation(parsing: xmlDocument)
    }

    static func firstSubdirectory(parent: String) -> String? {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: parent)
                .map { "\(parent)\\\($0)" }
                .first {
                    var isDirectory: ObjCBool = false
                    return FileManager.default.fileExists(atPath: $0, isDirectory: &isDirectory) && isDirectory.boolValue
                }
        } catch {
            return nil
        }
    }
}