// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SCEnforcement-CLI",
        dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
       .package(url:"https://github.com/compnerd/swift-win32.git",branch:"main"),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SCEnforcement-CLI",
            dependencies: [.product(name: "SwiftWin32", package: "swift-win32"),],
            path: "Sources"),
    ]
)
