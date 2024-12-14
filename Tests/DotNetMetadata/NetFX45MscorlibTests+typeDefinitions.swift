import Foundation
import Testing
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    @Test func testTypeGenericParamEnumeration() throws {
        // Interface with 1 generic parameter
        let action1 = try #require(try assembly.resolveTypeDefinition(fullName: "System.Action`1"))
        #expect(try action1.genericParams.map({ $0.name }) == [ "T" ])

        // Delegate with 2 generic parameters
        let action2 = try #require(try assembly.resolveTypeDefinition(fullName: "System.Action`2"))
        #expect(try action2.genericParams.map({ $0.name }) == [ "T1", "T2" ])
    }
}
