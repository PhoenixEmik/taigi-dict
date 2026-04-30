import SwiftUI
import TaigiDictCore

public struct TaigiDictAppRootView: View {
    @State private var viewModel: DictionarySearchViewModel
    @State private var initializationViewModel = InitializationViewModel()
    @State private var bookmarkStore = BookmarkStore()

    public init(repository: any DictionaryRepositoryProtocol) {
        _viewModel = State(initialValue: DictionarySearchViewModel(repository: repository))
    }

    public var body: some View {
        Group {
            switch initializationViewModel.state {
            case .ready:
                mainTabView
            case .idle, .loading, .failed:
                InitializationScreen(state: initializationViewModel.state) {
                    initializationViewModel.retry()
                }
            }
        }
        .task(id: initializationViewModel.taskID) {
            await initializationViewModel.prepare(using: viewModel)
        }
    }

    private var mainTabView: some View {
        TabView {
            DictionarySearchScreen(viewModel: viewModel, bookmarkStore: bookmarkStore)
                .tabItem {
                    Label("辭典", systemImage: "book")
                }

            BookmarksScreen(library: viewModel.library, bookmarkStore: bookmarkStore)
            .tabItem {
                Label("書籤", systemImage: "bookmark")
            }

            SettingsScreen(library: viewModel.library) {
                Task { @MainActor in
                    await viewModel.resetAfterMaintenance()
                    initializationViewModel.retry()
                }
            }
            .tabItem {
                Label("設定", systemImage: "gearshape")
            }
        }
    }
}
