/// A half-open range of bytes in a source: `start ..< end`.
///
/// Offsets are `Int` and never negative, so a range that exists is a range a reader can use. Whether it lies inside a given
/// source is that source's question (``contained(in:)``); a range does not know its source.
public struct ByteRange: Hashable, Sendable {
    public let start: Int
    public let end: Int

    /// The range `start ..< end`, or nil when `start` is negative or `end` is before `start`. An empty range is allowed: it is a position.
    public init?(start: Int, end: Int) {
        guard start >= 0, end >= start else { return nil }
        self.start = start
        self.end = end
    }

    /// How many bytes it covers.
    public var length: Int { end - start }

    /// Whether it covers no byte.
    public var isEmpty: Bool { start == end }

    /// Whether the byte at `offset` is inside it.
    public func contains(_ offset: Int) -> Bool { offset >= start && offset < end }

    /// Whether it ends at or before `count`, the length of a source.
    public func contained(in count: Int) -> Bool { end <= count }

    /// The smallest range covering both.
    public func union(_ other: ByteRange) -> ByteRange {
        // Both bounds come from valid ranges, so the result is valid; no failable path is needed.
        ByteRange(uncheckedStart: min(start, other.start), end: max(end, other.end))
    }

    private init(uncheckedStart start: Int, end: Int) {
        self.start = start
        self.end = end
    }
}
