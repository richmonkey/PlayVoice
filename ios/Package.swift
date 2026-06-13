// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GoogleSignInDemo",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "7.1.0"),
    ],
    targets: [
        .target(
            name: "GoogleSignInDemo",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            path: "GoogleSignInDemo",
            sources: ["Presentation", "Domain", "Data", "Infrastructure"],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"], .when(configuration: .debug))
            ]
        ),
    ]
)
