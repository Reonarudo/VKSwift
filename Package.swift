// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
// \swift
import PackageDescription

let package = Package(
    name: "VKSwift",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
   targets: [
        // Targets are the basic building blocks of a package. Aswiftget can define a module or a test suite.
        // Targets can depend on otherswiftgets in this package, and on products in packages which this package depends on.
        .systemLibrary(name: "CVulkan", pkgConfig: "vulkan"),
        .systemLibrary(name: "CGLFW", pkgConfig: "glfw3"),
		.target(
            name: "VKSwift",
            dependencies: ["CVulkan","CGLFW"]),
        .testTarget(
            name: "VKSwiftTests",
            dependencies: ["VKSwift"]),
    ]
)
