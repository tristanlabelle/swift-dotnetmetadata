import Foundation
import XCTest
@testable import DotNetMD

extension DotNet45MscorlibTests {
    func testTypePropertyEnumeration() throws {
        XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.IAsyncResult")?.properties.map({ $0.name }).sorted(),
            [ "AsyncState", "AsyncWaitHandle", "CompletedSynchronously", "IsCompleted" ])
    }
 
    func testPropertyType() throws {
        try XCTAssertEqual(
            Self.assembly.findDefinedType(fullName: "System.String")?
                .findProperty(name: "Length")?.type.asUnbound?.fullName,
            "System.Int32")
    }

    func testPropertyAccessors() throws {
        let console_Title = Self.assembly.findDefinedType(fullName: "System.Console")?
                .findProperty(name: "Title")
        try XCTAssertNotNil(console_Title?.getter)
        try XCTAssertNotNil(console_Title?.setter)
        
        let string_Length = Self.assembly.findDefinedType(fullName: "System.String")?
                .findProperty(name: "Length")
        try XCTAssertNotNil(string_Length?.getter)
        try XCTAssertNil(string_Length?.setter)
    }
}
