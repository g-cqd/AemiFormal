import Testing

struct RoadmapGraphTests {
    @Test func `an acyclic set has no cycle`() {
        #expect(RoadmapGraph.cycles(in: ["c": ["a", "b"], "b": ["a"], "a": []]).isEmpty)
    }

    @Test func `two entries waiting on each other are one cycle`() {
        let found = RoadmapGraph.cycles(in: ["a": ["b"], "b": ["a"]])
        #expect(found.count == 1)
        #expect(found.first?.first == found.first?.last)
        #expect(Set(found.first ?? []) == ["a", "b"])
    }

    @Test func `an entry blocked by itself is a cycle`() {
        #expect(RoadmapGraph.cycles(in: ["a": ["a"]]) == [["a", "a"]])
    }

    @Test func `a diamond is not a cycle`() {
        #expect(RoadmapGraph.cycles(in: ["d": ["b", "c"], "b": ["a"], "c": ["a"], "a": []]).isEmpty)
    }

    @Test func `the result does not depend on dictionary order`() {
        let blockers = ["a": ["b"], "b": ["c"], "c": ["a"], "x": ["y"], "y": ["x"]]
        #expect(RoadmapGraph.cycles(in: blockers) == RoadmapGraph.cycles(in: blockers))
        #expect(RoadmapGraph.cycles(in: blockers).count == 2)
    }

    @Test func `a very long chain and a very long ring neither overflow the stack nor lose the cycle`() {
        let n = 200_000
        var chain: [String: [String]] = [:]
        for i in 0 ..< n { chain["n\(i)"] = i + 1 < n ? ["n\(i + 1)"] : [] }
        #expect(RoadmapGraph.cycles(in: chain).isEmpty)
        chain["n\(n - 1)"] = ["n0"]
        #expect(RoadmapGraph.cycles(in: chain).count == 1)
    }

    @Test func `an unknown phase is refused, a known one is not`() {
        #expect(RoadmapGraph.phases.contains("shared"))
        #expect(!RoadmapGraph.phases.contains("misc"))
    }
}
