import Testing

@testable import FormalSupport

struct DiagnosticTests {
    private func at(_ start: Int, _ end: Int) throws -> ByteRange {
        try #require(ByteRange(start: start, end: end))
    }

    @Test func `severities order a note below a warning below an error`() {
        #expect(Diagnostic.Severity.note < .warning)
        #expect(Diagnostic.Severity.warning < .error)
    }

    @Test func `diagnostics sort by position, then the worse severity first, then message`() throws {
        let late = Diagnostic(.error, at: try at(9, 10), "late")
        let warning = Diagnostic(.warning, at: try at(1, 2), "w")
        let error = Diagnostic(.error, at: try at(1, 2), "e")
        let wide = Diagnostic(.error, at: try at(1, 5), "wide")
        let b = Diagnostic(.error, at: try at(1, 2), "b")
        #expect([late, warning, wide, error, b].sorted() == [b, error, warning, wide, late])
    }

    @Test func `sorting does not depend on the order diagnostics were found in`() throws {
        let all = [
            Diagnostic(.note, at: try at(3, 3), "n"), Diagnostic(.error, at: try at(0, 1), "a"),
            Diagnostic(.warning, at: try at(3, 4), "w"), Diagnostic(.error, at: try at(3, 3), "e")
        ]
        #expect(all.sorted() == all.reversed().sorted())
    }
}
