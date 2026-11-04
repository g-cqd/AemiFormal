/// The dependency structure of the roadmap: which entries wait on which.
enum RoadmapGraph {
    /// The phases an entry may belong to: shared kernels, the TLA+ line, the Lean line, proofs and solvers, and the services on top.
    static let phases: Set<String> = ["shared", "tla", "lean", "proof", "services"]

    /// The milestones, in the order work reaches them: M0 foundations, M1 front end, M2 safety checking, M3 fast and parallel,
    /// M4 liveness and reductions, M5 Lean checking, M6 Lean hosting, M7 proofs and solvers, M8 services.
    static let milestones: [String] = (0 ... 8).map { "M\($0)" }

    /// Cycles among `blockers` (entry to the entries it waits on): one path per back edge found, each starting and ending at the same
    /// entry. Depth-first on an explicit stack, entries taken in sorted order, so the answer is the same on every run and a chain of any
    /// length cannot overflow the call stack. Entries named only as blockers have no blockers themselves.
    static func cycles(in blockers: [String: [String]]) -> [[String]] {
        enum Mark { case onPath, finished }
        var marks: [String: Mark] = [:]
        var found: [[String]] = []
        for root in blockers.keys.sorted() where marks[root] == nil {
            var path = [root]
            var nextEdge = [0]
            marks[root] = .onPath
            while let node = path.last {
                let edges = blockers[node] ?? []
                let index = nextEdge[nextEdge.count - 1]
                guard index < edges.count else {
                    marks[node] = .finished
                    path.removeLast()
                    nextEdge.removeLast()
                    continue
                }
                nextEdge[nextEdge.count - 1] = index + 1
                let target = edges[index]
                switch marks[target] {
                    case nil:
                        marks[target] = .onPath
                        path.append(target)
                        nextEdge.append(0)
                    case .onPath:
                        if let start = path.lastIndex(of: target) { found.append(Array(path[start...]) + [target]) }
                    case .finished:
                        break
                }
            }
        }
        return found
    }
}
