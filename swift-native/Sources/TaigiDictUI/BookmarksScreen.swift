import SwiftUI
import TaigiDictCore

public struct BookmarksScreen: View {
    @State private var viewModel: BookmarksViewModel
    private let library: DictionaryLibrary
    private let bookmarkStore: any BookmarksStoreProtocol
    private let offlineAudioStore: (any OfflineAudioManaging)?

    public init(
        library: DictionaryLibrary,
        bookmarkStore: any BookmarksStoreProtocol,
        offlineAudioStore: (any OfflineAudioManaging)? = nil
    ) {
        self.library = library
        self.bookmarkStore = bookmarkStore
        self.offlineAudioStore = offlineAudioStore
        _viewModel = State(initialValue: BookmarksViewModel(library: library, bookmarkStore: bookmarkStore))
    }

    public var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("載入書籤中")
                        }
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Section {
                        ContentUnavailableView(
                            "載入失敗",
                            systemImage: "exclamationmark.triangle",
                            description: Text(errorMessage)
                        )
                    }
                } else if viewModel.entries.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "尚無書籤",
                            systemImage: "bookmark",
                            description: Text("在詞條頁按下書籤按鈕後，會顯示在這裡。")
                        )
                    }
                } else {
                    Section("已收藏詞條") {
                        ForEach(viewModel.entries) { entry in
                            Button {
                                viewModel.detailEntry = entry
                            } label: {
                                DictionaryEntryRowView(entry: entry)
                            }
                            .foregroundStyle(.primary)
                        }
                        .onDelete { offsets in
                            Task {
                                await viewModel.removeBookmarks(at: offsets)
                            }
                        }
                    }
                }
            }
            .navigationTitle("書籤")
            .navigationDestination(item: $viewModel.detailEntry) { entry in
                DictionaryDetailView(
                    entry: entry,
                    library: library,
                    bookmarkStore: bookmarkStore,
                    offlineAudioStore: offlineAudioStore
                ) { _ in }
                .navigationTitle(entry.hanji)
                .taigiInlineNavigationTitle()
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
