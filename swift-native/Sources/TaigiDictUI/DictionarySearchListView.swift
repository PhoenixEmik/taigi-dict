import SwiftUI
import TaigiDictCore

struct DictionarySearchListView: View {
    @Bindable var viewModel: DictionarySearchViewModel
    var showsSelection: Bool

    private var selectedEntryID: Binding<Int64?> {
        Binding(
            get: { viewModel.selectedEntry?.id },
            set: { newID in
                guard let newID else {
                    viewModel.selectedEntry = nil
                    return
                }

                if let matched = viewModel.results.first(where: { $0.id == newID }) {
                    viewModel.selectedEntry = matched
                }
            }
        )
    }

    var body: some View {
        List(selection: showsSelection ? selectedEntryID : .constant(nil)) {
            if viewModel.isLoading {
                Section {
                    HStack {
                        ProgressView()
                        Text("載入辭典資料中")
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
            } else if viewModel.normalizedQuery.isEmpty {
                SearchStartContentView(history: viewModel.searchHistory) { query in
                    viewModel.applyHistoryQuery(query)
                } clearHistory: {
                    viewModel.clearSearchHistory()
                }
            } else if viewModel.isSearching {
                Section {
                    HStack {
                        ProgressView()
                        Text("搜尋中")
                    }
                }
            } else if viewModel.results.isEmpty {
                Section {
                    ContentUnavailableView(
                        "查無結果",
                        systemImage: "magnifyingglass",
                        description: Text("試試改用漢字、羅馬字或華語詞義。")
                    )
                }
            } else {
                Section("搜尋結果") {
                    ForEach(viewModel.results) { entry in
                        if showsSelection {
                            DictionaryEntryRowView(entry: entry)
                                .tag(entry.id)
                        } else {
                            Button {
                                viewModel.select(entry)
                            } label: {
                                DictionaryEntryRowView(entry: entry)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "輸入台語漢字、白話字或華語詞義")
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.scheduleSearch()
        }
        .onSubmit(of: .search) {
            viewModel.submitSearch()
        }
    }
}
