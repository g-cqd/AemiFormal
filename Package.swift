// swift-tools-version: 6.4
import PackageDescription

// Same strictness as the AemiJSON family: Swift 6 mode (complete concurrency checking), warnings as errors, and the upcoming
// features that tighten existentials and imports. No unsafe flags, so the libraries can be consumed through a version-pinned
// requirement.
let strictSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .treatAllWarnings(as: .error),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("MemberImportVisibility")
]

// Targets that read attacker-controlled bytes (a specification, a configuration, an export file) or hold the search's shared
// state: every unsafe construct in them must be marked `unsafe` and justified where it stands.
let kernelSettings: [SwiftSetting] = strictSettings + [.strictMemorySafety()]

// Aemi is not a dependency yet: the first target that needs a kernel (hashing, interning, byte reading) adds it, pinned to the
// revision AemiJSON, AemiRegex and AemiMarkdown pin (docs/roadmap/0007, aemi ADR-0030). Nothing here imports it, so nothing declares it.
let package = Package(
    name: "AemiFormal",
    // The family's floor (docs/adr/0002). Model checking is a server and CI workload, so Linux is built and tested too.
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .visionOS(.v2)],
    products: [
        // Source ranges and diagnostics: what every other target reports errors with.
        .library(name: "FormalSupport", targets: ["FormalSupport"])
    ],
    targets: [
        .target(name: "FormalSupport", swiftSettings: kernelSettings),
        .testTarget(
            name: "AemiFormalTests",
            dependencies: ["FormalSupport"],
            swiftSettings: strictSettings
        )
    ]
)
