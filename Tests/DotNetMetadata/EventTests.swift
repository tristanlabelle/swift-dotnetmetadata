@testable import DotNetMetadata
import XCTest

internal final class EventTests: CompiledAssemblyTestCase {
    internal override class var csharpCode: String {
        """
        delegate void Delegate();
        class Events {
            public event Delegate PublicInstance;
            private static event Delegate PrivateStatic;
        }
        """
    }

    private var delegateDefinition: DelegateDefinition!
    private var eventsClassDefinition: ClassDefinition!

    public override func setUpWithError() throws {
        try super.setUpWithError()
        delegateDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Delegate") as? DelegateDefinition)
        eventsClassDefinition = try XCTUnwrap(assembly.resolveTypeDefinition(fullName: "Events") as? ClassDefinition)
    }

    public func testEnumeration() throws {
        XCTAssertEqual(
            eventsClassDefinition.events.map { $0.name },
            ["PublicInstance", "PrivateStatic"])
    }

    public func testAccessors() throws {
        let event = try XCTUnwrap(eventsClassDefinition.findEvent(name: "PublicInstance"))
        XCTAssertEqual(try XCTUnwrap(event.addAccessor).name, "add_PublicInstance")
        XCTAssertEqual(try XCTUnwrap(event.removeAccessor).name, "remove_PublicInstance")
    }

    public func testHandlerType() throws {
        let event = try XCTUnwrap(eventsClassDefinition.findEvent(name: "PublicInstance"))
        XCTAssertEqual(try event.handlerType, delegateDefinition.bind())
    }
}