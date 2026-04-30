import SwiftUI
import TaigiDictCore

struct DictionarySearchListView: View {
    @Bindable var viewModel: DictionarySearchViewModel
    var showsSelection: Bool

    var body: some View {
        List {
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
        .searchable(text: $viewModel.searchText, prompt: "輸入台語漢字、白話字或華語詞義")
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.scheduleSearch()
        }
        .onSubmit(of: .search) {
            viewModel.submitSearch()
        }
    }
}
