import WinMD

public class MetadataContext {
    struct MetadataKey: Hashable {
        var token: MetadataToken
        var database: Database

        func hash(into hasher: inout Hasher) {
            hasher.combine(token)
            hasher.combine(ObjectIdentifier(database))
        }

        static func == (lhs: MetadataContext.MetadataKey, rhs: MetadataContext.MetadataKey) -> Bool {
            lhs.token == rhs.token && ObjectIdentifier(lhs.database) == ObjectIdentifier(rhs.database)
        }
    }

}