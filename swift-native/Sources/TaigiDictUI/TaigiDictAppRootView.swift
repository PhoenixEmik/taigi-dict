import SwiftUI
import TaigiDictCore

public struct TaigiDictAppRootView: View {
    @State private var viewModel: DictionarySearchViewModel

    public init(repository: any DictionaryRepositoryProtocol) {
        _viewModel = State(initialValue: DictionarySearchViewModel(repository: repository))
    }

    public var body: some View {
        DictionarySearchScreen(viewModel: viewModel)
            .task {
                await viewModel.load()
            }
    }
}

public struct DictionarySearchScreen: View {
    @Bindable private var viewModel: DictionarySearchViewModel

    public init(viewModel: DictionarySearchViewModel) {
        _viewModel = Bindable(viewModel)
    }

    public var body: some View {
        NavigationSplitView {
            SearchSidebar(viewModel: viewModel)
                .navigationTitle("辭典")
        } detail: {
            DictionaryDetailPane(entry: viewModel.selectedEntry)
                .navigationTitle(viewModel.selectedEntry?.hanji ?? "辭典")
        }
        .background(DictionaryBackdrop())
    }
}

private struct SearchSidebar: View {
    @Bindable var viewModel: DictionarySearchViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                SearchField(viewModel: viewModel)

                if viewModel.isLoading {
                    LoadingCard(text: "載入辭典資料中")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorCard(message: errorMessage)
                } else if viewModel.normalizedQuery.isEmpty {
                    SearchStartCard(history: viewModel.searchHistory) { query in
                        viewModel.applyHistoryQuery(query)
                    } clearHistory: {
                        viewModel.clearSearchHistory()
                    }
                } else if viewModel.isSearching {
                    LoadingCard(text: "搜尋中")
                } else {
                    ResultList(
                        results: viewModel.results,
                        selectedEntry: viewModel.selectedEntry,
                        select: viewModel.select
                    )
                }
            }
            .padding(22)
        }
        .scrollContentBackground(.hidden)
    }
}

private struct SearchField: View {
    @Bindable var viewModel: DictionarySearchViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.blue)

            TextField("輸入台語漢字、白話字或華語詞義", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.title3)
                .onChange(of: viewModel.searchText) { _, _ in
                    viewModel.scheduleSearch()
                }
                .onSubmit {
                    viewModel.submitSearch()
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.scheduleSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .taigiGlassProminent(cornerRadius: 22)
    }
}

private struct ResultList: View {
    var results: [DictionaryEntry]
    var selectedEntry: DictionaryEntry?
    var select: (DictionaryEntry) -> Void

    var body: some View {
        LazyVStack(spacing: 14) {
            if results.isEmpty {
                EmptyStateCard(title: "查無結果", message: "試試改用漢字、羅馬字或華語詞義。")
            } else {
                ForEach(results) { entry in
                    Button {
                        select(entry)
                    } label: {
                        EntryRow(entry: entry, isSelected: selectedEntry?.id == entry.id)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct EntryRow: View {
    var entry: DictionaryEntry
    var isSelected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(entry.hanji)
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(isSelected ? .blue : .primary)
                Text(entry.romanization)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.orange)
                Text(entry.briefSummary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .taigiGlassCard(cornerRadius: 24)
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isSelected ? Color.blue.opacity(0.55) : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
        }
    }
}

private struct DictionaryDetailPane: View {
    var entry: DictionaryEntry?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if let entry {
                    DetailHeader(entry: entry)
                    ForEach(Array(entry.senses.enumerated()), id: \.offset) { _, sense in
                        SenseSection(sense: sense)
                    }
                } else {
                    EmptyStateCard(title: "開始搜尋", message: "輸入台語漢字、白話字或華語詞義後，詞條內容會顯示在這裡。")
                }
            }
            .padding(28)
            .frame(maxWidth: 860, alignment: .leading)
        }
        .scrollContentBackground(.hidden)
    }
}

private struct DetailHeader: View {
    var entry: DictionaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.hanji)
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(.blue)
                    Text(entry.romanization)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.orange)
                    Text([entry.type, entry.category].filter { !$0.isEmpty }.joined(separator: " · "))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2.weight(.semibold))
                        .frame(width: 54, height: 54)
                }
                .buttonStyle(.plain)
                .taigiGlassProminent(cornerRadius: 27)
            }
        }
        .padding(24)
        .taigiGlassCard(cornerRadius: 30)
    }
}

private struct SenseSection: View {
    var sense: DictionarySense

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !sense.partOfSpeech.isEmpty {
                Text(sense.partOfSpeech)
                    .font(.headline.weight(.bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .taigiGlassProminent(cornerRadius: 16)
            }

            Text(sense.definition)
                .font(.title3.weight(.semibold))
                .lineSpacing(6)

            ForEach(Array(sense.examples.enumerated()), id: \.offset) { _, example in
                ExampleCard(example: example)
            }
        }
    }
}

private struct ExampleCard: View {
    var example: DictionaryExample

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(example.hanji)
                .font(.headline.weight(.semibold))
            Text(example.romanization)
                .font(.callout)
                .foregroundStyle(.orange)
            Text(example.mandarin)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .taigiGlassCard(cornerRadius: 22)
    }
}

private struct SearchStartCard: View {
    var history: [String]
    var applyHistory: (String) -> Void
    var clearHistory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("開始搜尋")
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            Text("輸入台語漢字、白話字或華語詞義後才顯示詞條。")
                .font(.title3)
                .foregroundStyle(.secondary)

            if !history.isEmpty {
                HStack {
                    Text("搜尋紀錄")
                        .font(.headline.weight(.bold))
                    Spacer()
                    Button("清除", action: clearHistory)
                }

                FlowLayout(items: history, action: applyHistory)
            }
        }
        .padding(24)
        .taigiGlassCard(cornerRadius: 28)
    }
}

private struct FlowLayout: View {
    var items: [String]
    var action: (String) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 10)], alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button(item) {
                    action(item)
                }
                .buttonStyle(.plain)
                .font(.headline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .taigiGlassProminent(cornerRadius: 18)
            }
        }
    }
}

private struct LoadingCard: View {
    var text: String

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(text)
                .font(.headline)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .taigiGlassCard(cornerRadius: 24)
    }
}

private struct ErrorCard: View {
    var message: String

    var body: some View {
        EmptyStateCard(title: "載入失敗", message: message)
    }
}

private struct EmptyStateCard: View {
    var title: String
    var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
            Text(message)
                .font(.title3)
                .foregroundStyle(.secondary)
                .lineSpacing(5)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .taigiGlassCard(cornerRadius: 28)
    }
}

private struct DictionaryBackdrop: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.91, blue: 0.84),
                Color(red: 0.88, green: 0.95, blue: 0.95),
                Color(red: 0.95, green: 0.96, blue: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
