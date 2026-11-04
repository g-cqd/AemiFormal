import Testing

@testable import FormalSupport

struct ByteRangeTests {
    private func range(_ start: Int, _ end: Int) throws -> ByteRange {
        try #require(ByteRange(start: start, end: end))
    }

    @Test func `a range has the length between its bounds`() throws {
        #expect(try range(3, 10).length == 7)
    }

    @Test func `an empty range is allowed and a reversed or negative one is refused`() {
        #expect(ByteRange(start: 4, end: 4)?.length == 0)
        #expect(ByteRange(start: 4, end: 4)?.isEmpty == true)
        #expect(ByteRange(start: 5, end: 4) == nil)
        #expect(ByteRange(start: -1, end: 4) == nil)
    }

    @Test func `a range contains its first byte and not its end`() throws {
        let r = try range(2, 5)
        #expect(!r.contains(1))
        #expect(r.contains(2))
        #expect(r.contains(4))
        #expect(!r.contains(5))
    }

    @Test func `a range is contained in a source that is at least as long as its end`() throws {
        let r = try range(2, 5)
        #expect(r.contained(in: 5))
        #expect(!r.contained(in: 4))
    }

    @Test func `the union covers both ranges and the gap between them`() throws {
        let u = try range(2, 4).union(range(8, 9))
        #expect(u == (try range(2, 9)))
        #expect(try range(2, 9).union(range(3, 4)) == (try range(2, 9)))
    }
}
