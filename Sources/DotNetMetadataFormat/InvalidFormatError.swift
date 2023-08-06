public enum InvalidFormatError: Error {
    case dosHeader
    case ntHeader
    case cliHeader
    case heapOffset
    case tableID
    case signatureBlob
    case tableConstraint
}