// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Nocturnal",
    platforms: [
      .iOS(.v10)
    ],
    products: [
			.library(name: "NocturnalCore", targets: ["NocturnalCore"]),
    ],
		dependencies: [
			.package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
			.package(name: "RxGesture", url: "https://github.com/RxSwiftCommunity/RxGesture.git", .upToNextMajor(from: "4.0.0")),
			.package(name: "Sundial", url: "https://github.com/netcosports/Sundial.git", .upToNextMajor(from: "5.0.0")),
			.package(name: "Astrolabe", url: "https://github.com/netcosports/Astrolabe.git", .upToNextMajor(from: "5.0.0")),
			.package(name: "AlidadeUI", url: "https://github.com/netcosports/Alidade.git", .branch("master"))
		],
    targets: [
			.target(name: "NocturnalCore",
							dependencies: ["RxSwift", "RxCocoa", "RxGesture", "Sundial", "Astrolabe", "AlidadeUI"],
							path: "./Sources/Core"),
    ],
    swiftLanguageVersions: [.v5]
)
