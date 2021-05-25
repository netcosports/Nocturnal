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
			.package(name: "RxGesture", url: "https://github.com/RxSwiftCommunity/RxGesture.git", .upToNextMajor(from: "3.0.0")),
			.package(name: "Sundial", url: "https://github.com/netcosports/Sundial.git", .upToNextMajor(from: "5.1.23")),
			.package(name: "Astrolabe", url: "https://github.com/netcosports/Astrolabe.git", .upToNextMajor(from: "5.0.0")),
			.package(name: "Alidade", url: "https://github.com/netcosports/Alidade.git", .upToNextMajor(from: "5.1.9"))
		],
    targets: [
			.target(name: "NocturnalCore",
							dependencies: ["RxSwift",
														 .product(name: "RxCocoa", package: "RxSwift"),
														 "RxGesture",
														 "Sundial",
														 "Astrolabe",
														 .product(name: "AlidadeAssociatable", package: "Alidade"),
														 .product(name: "AlidadeUI", package: "Alidade")],
							path: "./Sources/Core"),
    ],
    swiftLanguageVersions: [.v5]
)
