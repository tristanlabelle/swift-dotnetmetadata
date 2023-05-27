extension Collection {
    func singleIndex(where: (Element) throws -> Bool) rethrows -> Index? {
        var foundIndex: Index? = nil
        for i in indices {
            if try `where`(self[i]) {
                guard foundIndex == nil else { return nil }
                foundIndex = i
            }
        }
        return foundIndex
    }

    func single(where: (Element) throws -> Bool) rethrows -> Element? {
        guard let index = try singleIndex(where: `where`) else { return nil }
        return self[index]
    }
}