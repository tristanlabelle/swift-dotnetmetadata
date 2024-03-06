@testable import DotNetMetadata
import DotNetMetadataFormat
import XCTest
import Foundation
import WinSDK

internal class CompiledAssemblyTestCase: XCTestCase {
    internal class var csharpCode: String { "" }

    private static var data: Result<CSharpCompilation, any Error>!

    internal var assemblyLoadContext: AssemblyLoadContext { try! Self.data.get().assemblyLoadContext }
    internal var assembly: Assembly { try! Self.data.get().assembly }

    public override class func setUp() {
        data = Result { try CSharpCompilation(code: csharpCode) }
    }

    public override func setUpWithError() throws {
        _ = try XCTUnwrap(Self.data).get()
    }

    public override class func tearDown() {
        data = nil
    }
}