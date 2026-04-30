import SwiftUI
import TaigiDictCore
import TaigiDictUI

@main
struct TaigiDictNativeApp: App {
    var body: some Scene {
        WindowGroup {
            TaigiDictAppRootView(
                repository: PackageDictionaryRepository(
                    packageDirectory: Self.dictionaryDirectory
                )
            )
        }
    }

    private static var dictionaryDirectory: URL {
        guard let url = Bundle.main.url(forResource: "Dictionary", withExtension: nil) else {
            preconditionFailure("Bundled dictionary package is missing.")
        }
        return url
    }
}
