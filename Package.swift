// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DrugLog",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DrugLog",
            targets: ["DrugLog"]),
    ],
    dependencies: [
        // Dependencies can be added here
    ],
    targets: [
        .target(
            name: "DrugLog",
            dependencies: [],
            path: "DrugLog/DrugLog",
            resources: [
                .process("Resources/medlist.json"),
            ]),
        .testTarget(
            name: "DrugLogTests",
            dependencies: ["DrugLog"],
            path: "DrugLog/DrugLogTests"),
    ]
)
