import SwiftUI
import TaigiDictCore
import TaigiDictUI

@main
struct TaigiDictPreviewApp: App {
    var body: some Scene {
        WindowGroup {
            TaigiDictAppRootView(
                repository: PackageDictionaryRepository(
                    packageDirectory: Self.generatedDictionaryDirectory
                )
            )
        }
    }

    private static var generatedDictionaryDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Generated/Dictionary")
    }
}
