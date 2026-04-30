import SwiftUI

struct SearchStartContentView: View {
    var history: [String]
    var applyHistory: (String) -> Void
    var clearHistory: () -> Void

    var body: some View {
        Section {
            ContentUnavailableView(
                "開始搜尋",
                systemImage: "text.magnifyingglass",
                description: Text("輸入台語漢字、白話字，或華語釋義後才顯示詞條。")
            )
        }

        if !history.isEmpty {
            Section {
                ForEach(history, id: \.self) { query in
                    Button {
                        applyHistory(query)
                    } label: {
                        Label(query, systemImage: "clock.arrow.circlepath")
                    }
                }
                Button(role: .destructive, action: clearHistory) {
                    Label("清除搜尋紀錄", systemImage: "trash")
                }
            } header: {
                Text("搜尋紀錄")
            }
        }
    }
}
