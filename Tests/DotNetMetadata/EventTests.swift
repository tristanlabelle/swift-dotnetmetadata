@testable import DotNetMetadata
import Testing

internal final class EventTests {
    private var compilation: CSharpCompilation
    private var assembly: Assembly { compilation.assembly }
    private var delegateDefinition: DelegateDefinition
    private var eventsClassDefinition: ClassDefinition

    init() throws {
        compilation = try CSharpCompilation(code: 
        """
        delegate void Delegate();
        class Events {
            public event Delegate PublicInstance;
            private static event Delegate PrivateStatic;
        }
        """)

        delegateDefinition = try #require(compilation.assembly.resolveTypeDefinition(fullName: "Delegate") as? DelegateDefinition)
        eventsClassDefinition = try #require(compilation.assembly.resolveTypeDefinition(fullName: "Events") as? ClassDefinition)
    }

    @Test func testEnumeration() throws {
        #expect(eventsClassDefinition.events.map { $0.name } == ["PublicInstance", "PrivateStatic"])
    }

    @Test func testAccessors() throws {
        let event = try #require(eventsClassDefinition.findEvent(name: "PublicInstance"))
        #expect(try #require(event.addAccessor).name == "add_PublicInstance")
        #expect(try #require(event.removeAccessor).name == "remove_PublicInstance")
    }

    @Test func testHandlerType() throws {
        let event = try #require(eventsClassDefinition.findEvent(name: "PublicInstance"))
        #expect(try event.handlerType == delegateDefinition.bind())
    }
}