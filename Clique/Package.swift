// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Clique",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/jwt-provider.git", from: "1.0.0")
        //.package(url: "https://github.com/jwt.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Clique",
            dependencies: ["Vapor", "JWTProvider"])
    ]
)
