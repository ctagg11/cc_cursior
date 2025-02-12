// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CanvasCodexCursior",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
        .package(url: "https://github.com/WeTransfer/WeScan.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "CanvasCodexCursior",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
                .product(name: "WeScan", package: "WeScan")
            ]
        )
    ]
) 