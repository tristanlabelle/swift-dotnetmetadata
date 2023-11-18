extension Substring {
    internal mutating func consume(while predicate: (Character) -> Bool) -> Substring {
        var index = startIndex
        while index < endIndex && predicate(self[index]) {
            index = self.index(after: index)
        }

        let result = self[..<index]
        self = self[index...]
        return result
    }

    internal mutating func tryConsume(_ prefix: Character) -> Bool {
        guard self.first == prefix else { return false }
        self = self.dropFirst()
        return true
    }
}

internal func consumeIdentifier(_ remainder: inout Substring, allowConstructor: Bool = false) throws -> Substring {
    let constructorName = "#ctor"
    if allowConstructor && remainder.starts(with: constructorName) {
        let original = remainder
        remainder.removeFirst(constructorName.count)
        return original[..<remainder.startIndex]
    }

    let originalRemainder = remainder

    if let char = remainder.first, char.isLetter || char == "_" {
        remainder = remainder.dropFirst()
    }
    else {
        throw DocumentationFormatError()
    }

    while let char = remainder.first, char.isLetter || char.isNumber || char == "_" {
        remainder = remainder.dropFirst()
    }

    return originalRemainder[..<remainder.startIndex]
}
