import struct Foundation.UUID

// https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system#guid-generation-for-parameterized-types
fileprivate let parameterizedInterfaceGuidBytes: [UInt8] = [
    0x11, 0xf4, 0x7a, 0xd5,
    0x7b, 0x73,
    0x42, 0xc0,
    0xab, 0xae, 0x87, 0x8b, 0x1e, 0x16, 0xad, 0xee
];

extension WinRTTypeSignature {
    public var parameterizedID: UUID {
        get {
            switch self {
                case let .interface(_, args), let .delegate(_, args): precondition(!args.isEmpty)
                default: preconditionFailure("Only interfaces and delegates have parameterized IDs")
            }

            var sha1 = SHA1()
            sha1.process(parameterizedInterfaceGuidBytes)
            sha1.process(Array(self.toString().utf8))
            let hash = sha1.finalize()

            return UUID(uuid: (
                hash[0], hash[1], hash[2], hash[3],
                hash[4], hash[5],
                (hash[6] & 0x0F) | 0x50, hash[7],
                (hash[8] & 0x3F) | 0x80, hash[9],
                hash[10], hash[11], hash[12], hash[13], hash[14], hash[15]))
        }
    }
}