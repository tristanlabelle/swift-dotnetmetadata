import Foundation
import Testing
@testable import DotNetMetadata

extension NetFX45MscorlibTests {
    @Test func testTypeMethodEnumeration() throws {
        let equalityComparer = try #require(try assembly.resolveTypeDefinition(fullName: "System.Collections.Generic.EqualityComparer`1"))
        #expect(try equalityComparer.methods.map({ $0.name }).sorted() == [ "Equals", "GetHashCode" ])
    }

    @Test func testMethodClass() throws {
        let object = try #require(try assembly.resolveTypeDefinition(fullName: "System.Object"))
        #expect(object.findMethod(name: "ToString") is Constructor)
        #expect(object.findMethod(name: Constructor.name) is Constructor)
    }

    @Test func testMethodFlags() throws {
        // Abstract interface method
        let iasyncResult = try #require(try assembly.resolveTypeDefinition(fullName: "System.IAsyncResult"))
        let iasyncResult_get_IsCompleted = try #require(try iasyncResult.findMethod(name: "get_IsCompleted"))
        #expect(iasyncResult_get_IsCompleted.isStatic == false)
        #expect(iasyncResult_get_IsCompleted.isInstance == true)
        #expect(iasyncResult_get_IsCompleted.isVirtual == true)
        #expect(iasyncResult_get_IsCompleted.isAbstract == true)
        #expect(iasyncResult_get_IsCompleted.nameKind == NameKind.special)

        // Static method
        let gc = try #require(try assembly.resolveTypeDefinition(fullName: "System.GC"))
        let gc_WaitForPendingFinalizers = try #require(try gc.findMethod(name: "WaitForPendingFinalizers"))
        #expect(gc_WaitForPendingFinalizers.isStatic == true)
        #expect(gc_WaitForPendingFinalizers.isInstance == false)
        #expect(gc_WaitForPendingFinalizers.isVirtual == false)
        #expect(gc_WaitForPendingFinalizers.isAbstract == false)
        #expect(gc_WaitForPendingFinalizers.nameKind == NameKind.regular)

        // Overriden virtual method
        let exception = try #require(try assembly.resolveTypeDefinition(fullName: "System.Exception")?)
        let exception_ToString = try #require(try exception.findMethod(name: "ToString", public: true, arity: 0))
        #expect(exception_ToString.isStatic == false)
        #expect(exception_ToString.isInstance == true)
        #expect(exception_ToString.isVirtual == true)
        #expect(exception_ToString.isNewSlot == false)
        #expect(exception_ToString.isOverride == true)
    }

    @Test func testMethodParamEnumeration() throws {
        let object = try #require(try assembly.resolveTypeDefinition(fullName: "System.Object"))
        #expect(try #require(object.findMethod(name: "ReferenceEquals")).params.map { $0.name } == [ "objA", "objB" ])
        #expect(try #require(object.findMethod(name: "ToString")).params.count == 0)
    }

    @Test func testMethodHasReturnValue() throws {
        let object = try #require(try assembly.resolveTypeDefinition(fullName: "System.Object"))
        #expect(try #require(object.findMethod(name: "ToString")).hasReturnValue)

        let disposable = try #require(try assembly.resolveTypeDefinition(fullName: "System.IDisposable"))
        #expect(!try #require(disposable.findMethod(name: "Dispose")).hasReturnValue)
    }

    @Test func testMethodReturnType() throws {
        let object = try #require(try assembly.resolveTypeDefinition(fullName: "System.Object"))
        let object_toString = try #require(object.findMethod(name: "ToString"))
        #expect(try #require(object_toString.returnType.asDefinition).fullName == "System.String")

        let disposable = try #require(try assembly.resolveTypeDefinition(fullName: "System.IDisposable"))
        let disposable_dispose = try #require(disposable.findMethod(name: "Dispose"))
        #expect(try #require(disposable_dispose.returnType.asDefinition).fullName == "System.Void")
    }

    @Test func testMethodParamType() throws {
        let string = try #require(try assembly.resolveTypeDefinition(fullName: "System.String"))
        let string_isNullOrEmpty = try #require(string.findMethod(name: "IsNullOrEmpty"))
        #expect(try #require(string_isNullOrEmpty.params[0].type.asDefinition).fullName == "System.String")
    }

    @Test func testParamByRef() throws {
        let guid = try #require(try assembly.resolveTypeDefinition(fullName: "System.Guid"))
        let guid_tryParse = try #require(guid.findMethod(name: "TryParse"))
        #expect(try #require(guid_tryParse).params.map { $0.isByRef } == [ false, true ])
    }

    @Test func testOverloadBinding() throws {
        guard let convert = try assembly.resolveTypeDefinition(fullName: "System.Convert") else {
            return Issue.record("Failed to find System.Convert")
        }

        guard let toBooleanByte = convert.findMethod(name: "ToBoolean", paramTypes: [ try coreLibrary.systemByte.bindNode() ]),
            let toBooleanString = convert.findMethod(name: "ToBoolean", paramTypes: [ try coreLibrary.systemString.bindNode() ]) else {
            return Issue.record("Failed to find System.Convert.ToBoolean overloads")
        }

        #expect(toBooleanByte !== toBooleanString)
    }
}
