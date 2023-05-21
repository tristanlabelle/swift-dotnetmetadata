enum InvalidFormatError: Error {
    case dosHeader
    case ntHeader
    case cliHeader
    case heapOffset
    case tableIndex
    case signatureBlob
}