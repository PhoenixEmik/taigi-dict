import SwiftUI
import TaigiDictCore

public struct DictionarySearchScreen: View {
    @Bindable private var viewModel: DictionarySearchViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    public init(viewModel: DictionarySearchViewModel) {
        _viewModel = Bindable(viewModel)
    }

    public var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView {
                DictionarySearchListView(viewModel: viewModel, showsSelection: true)
                    .navigationTitle("辭典")
            } detail: {
                DictionaryDetailView(
                    entry: viewModel.selectedEntry,
                    library: viewModel.library
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
                            library: viewModel.library
                        ) { linkedEntry in
                            viewModel.select(linkedEntry)
                        }
                        .navigationTitle(entry.hanji)
                        .taigiInlineNavigationTitle()
                    }
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func taigiInlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
