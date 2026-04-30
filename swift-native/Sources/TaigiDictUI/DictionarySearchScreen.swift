import SwiftUI
import TaigiDictCore

public struct DictionarySearchScreen: View {
    @Bindable private var viewModel: DictionarySearchViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private let bookmarkStore: (any BookmarksStoreProtocol)?
    private let offlineAudioStore: (any OfflineAudioManaging)?

    public init(
        viewModel: DictionarySearchViewModel,
        bookmarkStore: (any BookmarksStoreProtocol)? = nil,
        offlineAudioStore: (any OfflineAudioManaging)? = nil
    ) {
        _viewModel = Bindable(viewModel)
        self.bookmarkStore = bookmarkStore
        self.offlineAudioStore = offlineAudioStore
    }

    public var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                DictionarySearchListView(viewModel: viewModel, showsSelection: true)
                    .navigationTitle("辭典")
            } detail: {
                DictionaryDetailView(
                    entry: viewModel.selectedEntry,
                    library: viewModel.library,
                    bookmarkStore: bookmarkStore,
                    offlineAudioStore: offlineAudioStore
                ) { entry in
                    viewModel.select(entry)
                }
                .navigationTitle(viewModel.selectedEntry?.hanji ?? "辭典")
            }
        } else {
            NavigationStack {
                DictionarySearchListView(viewModel: viewModel, showsSelection: false)
                    .navigationTitle("辭典")
                    .navigationDestination(item: $viewModel.detailEntry) { entry in
                        DictionaryDetailView(
                            entry: entry,
                            library: viewModel.library,
                            bookmarkStore: bookmarkStore,
                            offlineAudioStore: offlineAudioStore
                        ) { linkedEntry in
                            viewModel.select(linkedEntry)
                        }
                        .navigationTitle(entry.hanji)
                        #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                    }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func taigiInlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
