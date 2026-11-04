/// Something a front end or the checker reports about a source: a severity, where, and a sentence.
///
/// Diagnostics are values, ordered by position then severity, so a run reports them the same way every time.
public struct Diagnostic: Hashable, Sendable, Comparable {
    public enum Severity: Int, Hashable, Sendable, Comparable {
        case note
        case warning
        case error

        public static func < (lhs: Severity, rhs: Severity) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    public let severity: Severity
    public let range: ByteRange
    public let message: String

    public init(_ severity: Severity, at range: ByteRange, _ message: String) {
        self.severity = severity
        self.range = range
        self.message = message
    }

    /// By start, then end, then severity (the worse first), then message.
    public static func < (lhs: Diagnostic, rhs: Diagnostic) -> Bool {
        if lhs.range.start != rhs.range.start { return lhs.range.start < rhs.range.start }
        if lhs.range.end != rhs.range.end { return lhs.range.end < rhs.range.end }
        if lhs.severity != rhs.severity { return lhs.severity > rhs.severity }
        return lhs.message < rhs.message
    }
}
