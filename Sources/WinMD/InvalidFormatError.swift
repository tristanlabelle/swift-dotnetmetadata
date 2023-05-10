enum InvalidFormatError: Error {
    case invalidDOSHeader
    case invalidNTHeader
    case invalidCLIHeader
}