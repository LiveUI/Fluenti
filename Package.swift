// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Fluenti",
    products: [
        .library(name: "Fluenti", targets: ["Fluenti"]),
        .library(name: "Async", targets: ["Async"]),
        .library(name: "Bits", targets: ["Bits"]),
        .library(name: "CNIOAtomics", targets: ["CNIOAtomics"]),
        .library(name: "CNIODarwin", targets: ["CNIODarwin"]),
        .library(name: "CNIOLinux", targets: ["CNIOLinux"]),
        .library(name: "Command", targets: ["Command"]),
        .library(name: "Console", targets: ["Console"]),
        .library(name: "COperatingSystem", targets: ["COperatingSystem"]),
        .library(name: "Core", targets: ["Core"]),
//        .library(name: "CSQLite", targets: ["CSQLite"]),
        .library(name: "DatabaseKit", targets: ["DatabaseKit"]),
        .library(name: "Debugging", targets: ["Debugging"]),
        .library(name: "Fluent", targets: ["Fluent"]),
        .library(name: "FluentSQLite", targets: ["FluentSQLite"]),
        .library(name: "Logging", targets: ["Logging"]),
        .library(name: "NIO", targets: ["NIO"]),
        .library(name: "NIOConcurrencyHelpers", targets: ["NIOConcurrencyHelpers"]),
        .library(name: "NIOFoundationCompat", targets: ["NIOFoundationCompat"]),
        .library(name: "Service", targets: ["Service"]),
        .library(name: "SQLite", targets: ["SQLite"]),
        ],
    dependencies: [],
    targets: [
        .target(name: "Fluenti", dependencies: ["Fluent", "FluentSQLite"]),
        .target(name: "Async", dependencies: ["NIO"]),
        .target(name: "Bits", dependencies: ["Debugging", "NIO"]),
        .target(name: "CNIOAtomics", dependencies: []),
        .target(name: "CNIODarwin", dependencies: []),
        .target(name: "CNIOLinux", dependencies: []),
        .target(name: "Command", dependencies: ["Service", "Console"]),
        .target(name: "Console", dependencies: ["NIO", "Bits", "Logging", "Debugging", "Service"]),
        .target(name: "COperatingSystem", dependencies: []),
        .target(name: "Core", dependencies: ["COperatingSystem", "Bits", "Async", "NIOFoundationCompat"]),
//        .target(name: "CSQLite", dependencies: []),
        .target(name: "DatabaseKit", dependencies: ["NIO", "Service"]),
        .target(name: "Debugging", dependencies: []),
        .target(name: "Fluent", dependencies: ["Command", "Core", "DatabaseKit", "Logging"]),
        .target(name: "FluentSQLite", dependencies: ["SQLite", "Fluent"]),
        .target(name: "Logging", dependencies: ["NIO", "Core"]),
        .target(name: "NIO", dependencies: ["NIOConcurrencyHelpers", "CNIOLinux", "CNIODarwin"]),
        .target(name: "NIOConcurrencyHelpers", dependencies: ["CNIOAtomics"]),
        .target(name: "NIOFoundationCompat", dependencies: ["NIO"]),
        .target(name: "Service", dependencies: ["NIO", "Core"]),
        .target(name: "SQLite", dependencies: ["NIO", "Core", "DatabaseKit"]),
        .testTarget(name: "FluentiTests", dependencies: ["Fluenti"]),
    ]
)