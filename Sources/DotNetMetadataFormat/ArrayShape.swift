/// Represents static type information about the shape of a single- or multi-dimensional array.
public struct ArrayShape: Hashable, CustomStringConvertible {
    /// Represents one dimension of the array shape, with a lower bound and an optional size.
    /// Though it is not obvious in ECMA-335, the lower bound is always known statically.
    public struct Dimension: Hashable, CustomStringConvertible {
        public static var zeroBased: Dimension { Dimension(lowerBound: 0) }

        public var lowerBound: Int32
        public var size: UInt32?

        public init(lowerBound: Int32) {
            self.lowerBound = lowerBound
            self.size = nil
        }

        public init(lowerBound: Int32, size: UInt32?) {
            self.lowerBound = lowerBound
            self.size = size
        }

        public init(lowerBound: Int32, upperBound: Int32?) {
            self.lowerBound = lowerBound
            if let upperBound {
                precondition(upperBound >= lowerBound)
                self.size = UInt32(upperBound - lowerBound + 1)
            } else {
                self.size = nil
            }
        }

        public var upperBound: Int32? {
            guard let size else { return nil }
            return lowerBound + Int32(size) - 1
        }

        public var description: String {
            guard let upperBound else { return "\(lowerBound)..." }
            return "\(lowerBound)...\(upperBound)"
        }
    }

    /// Gets the dimensions
    public var dimensions: [Dimension] {
        willSet {
            precondition(newValue.count > 0)
        }
    }

    public init(dimensions: [Dimension]) {
        precondition(dimensions.count > 0)
        self.dimensions = dimensions
    }

    public init(_ sig: ArrayShapeSig) {
        precondition(sig.rank > 0)
        if sig.isVector { 
            // Reuse the allocated dimensions array.
            self.dimensions = Self.vector.dimensions
            return
        }

        var dimensions: [Dimension] = []
        for i in 0..<sig.rank {
            let lowerBound = i < sig.lowerBounds.count ? sig.lowerBounds[Int(i)] : 0
            let size = i < sig.sizes.count && sig.sizes[0] != 0 ? sig.sizes[Int(i)] : nil
            dimensions.append(Dimension(lowerBound: lowerBound, size: size))
        }
        self.dimensions = dimensions
    }

    public var rank: Int { dimensions.count }

    public var description: String {
        if self == ArrayShape.vector { return "[]" }
        var text = "["
        for (i, dimension) in dimensions.enumerated() {
            if i > 0 { text += "," }
            if dimension != .zeroBased { text += dimension.description }
        }
        text += "]"
        return text
    }

    public static let vector: ArrayShape = ArrayShape(dimensions: [.zeroBased])
}
