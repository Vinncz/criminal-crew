// swift-tools-version: 6.0

import PackageDescription

let package = Package (
    name: "criminal crew",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17)
    ],
    products: [
    ],
    dependencies: [
        .package(url: "https://github.com/Vinncz/GamePantry", .upToNextMajor(from: "0.2.5"))
    ],
    targets: [
        .target (
            name: "criminal crew",
            dependencies: [
                "GamePantry"
            ],
            path: "criminal crew",
            exclude: [
                "Info.plist",
                "Assets.xcassets",
                "Raws/Roboto_Mono/static/RobotoMono-ExtraLightItalic.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-SemiBoldItalic.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-ThinItalic.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-ExtraLight.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-Italic.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-Medium.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-Italic-VariableFont_wght.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-Regular.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-Thin.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-Bold.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-Light.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-BoldItalic.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-MediumItalic.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-SemiBold.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-VariableFont_wght.ttf",
                "Raws/Roboto_Mono/static/RobotoMono-LightItalic.ttf"
            ]
        )
    ]
)
