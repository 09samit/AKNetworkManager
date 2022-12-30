// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AKNetworkManager",
    products: [
        .library(
            name: "AKNetworkManager",
            targets: ["AKNetworkManager"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1"))
    ],
    targets: [
        .target(
            name: "AKNetworkManager",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "Sources"
        )
    ]
)
