// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "UygulamaSilici",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "UygulamaSilici", targets: ["UygulamaSilici"])
    ],
    targets: [
        .executableTarget(
            name: "UygulamaSilici",
            path: "Sources/UygulamaSilici"
        )
    ]
)
