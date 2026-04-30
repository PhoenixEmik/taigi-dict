import SwiftUI
import TaigiDictCore

public struct SettingsScreen: View {
    @State private var viewModel: SettingsViewModel
    private let onMaintenanceCompleted: () -> Void
    private let onSettingsChanged: (AppSettingsSnapshot) -> Void

    public init(
        library: DictionaryLibrary,
        settingsStore: any AppSettingsStoring = UserDefaultsAppSettingsStore(),
        offlineAudioStore: (any OfflineAudioManaging)? = nil,
        onMaintenanceCompleted: @escaping () -> Void = {},
        onSettingsChanged: @escaping (AppSettingsSnapshot) -> Void = { _ in }
    ) {
        _viewModel = State(
            initialValue: SettingsViewModel(
                library: library,
                settingsStore: settingsStore,
                offlineAudioStore: offlineAudioStore
            )
        )
        self.onMaintenanceCompleted = onMaintenanceCompleted
        self.onSettingsChanged = onSettingsChanged
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("顯示與語言") {
                    Picker("介面語言", selection: Binding(
                        get: { viewModel.selectedLocale },
                        set: { locale in
                            Task {
                                await viewModel.setLocale(locale)
                                onSettingsChanged(viewModel.currentSettingsSnapshot)
                            }
                        }
                    )) {
                        ForEach(AppLocale.allCases, id: \.self) { locale in
                            Text(locale.displayName)
                                .tag(locale)
                        }
                    }

                    Picker("主題", selection: Binding(
                        get: { viewModel.selectedThemePreference },
                        set: { preference in
                            Task {
                                await viewModel.setThemePreference(preference)
                                onSettingsChanged(viewModel.currentSettingsSnapshot)
                            }
                        }
                    )) {
                        ForEach(AppThemePreference.allCases, id: \.self) { preference in
                            Text(preference.displayName)
                                .tag(preference)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        LabeledContent("閱讀字級") {
                            Text(viewModel.readingTextScale.displayScaleLabel)
                                .monospacedDigit()
                        }

                        Slider(
                            value: Binding(
                                get: { viewModel.readingTextScale },
                                set: { value in
                                    Task {
                                        await viewModel.setReadingTextScale(value)
                                        onSettingsChanged(viewModel.currentSettingsSnapshot)
                                    }
                                }
                            ),
                            in: viewModel.minReadingTextScale...viewModel.maxReadingTextScale,
                            step: (viewModel.maxReadingTextScale - viewModel.minReadingTextScale) / Double(viewModel.readingTextScaleDivisions)
                        )
                    }
                }

                Section("資料與說明") {
                    NavigationLink {
                        AdvancedSettingsScreen(viewModel: viewModel) {
                            onMaintenanceCompleted()
                        }
                    } label: {
                        Label("進階設定", systemImage: "wrench.and.screwdriver")
                    }

                    NavigationLink {
                        AboutScreen()
                    } label: {
                        Label("關於", systemImage: "info.circle")
                    }

                    NavigationLink {
                        LicenseSummaryScreen()
                    } label: {
                        Label("授權資訊", systemImage: "doc.text")
                    }

                    NavigationLink {
                        ReferenceArticleListScreen()
                    } label: {
                        Label("參考資料", systemImage: "text.book.closed")
                    }
                }

                Section("離線音訊資源") {
                    AudioArchiveResourceRow(
                        title: "詞目音檔",
                        snapshot: viewModel.snapshot(for: .word),
                        isRunningAction: viewModel.isAudioActionRunning(for: .word)
                    ) { action in
                        Task {
                            await viewModel.runAudioAction(action, for: .word)
                        }
                    }

                    AudioArchiveResourceRow(
                        title: "例句音檔",
                        snapshot: viewModel.snapshot(for: .sentence),
                        isRunningAction: viewModel.isAudioActionRunning(for: .sentence)
                    ) { action in
                        Task {
                            await viewModel.runAudioAction(action, for: .sentence)
                        }
                    }
                }
            }
            .navigationTitle("設定")
        }
        .task {
            await viewModel.loadCapabilities()
            onSettingsChanged(viewModel.currentSettingsSnapshot)
        }
        .onAppear {
            viewModel.startAudioSnapshotPolling()
        }
        .onDisappear {
            viewModel.stopAudioSnapshotPolling()
        }
        .confirmationDialog(
            "確定要清除本機辭典資料？",
            isPresented: Binding(
                get: { viewModel.isClearConfirmationPresented },
                set: { isPresented in
                    if !isPresented {
                        viewModel.cancelClearConfirmation()
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("清除", role: .destructive) {
                Task {
                    if await viewModel.confirmClear() {
                        onMaintenanceCompleted()
                    }
                }
            }
            Button("取消", role: .cancel) {
                viewModel.cancelClearConfirmation()
            }
        } message: {
            Text("清除後會移除本機資料，下次使用前會重新初始化。")
        }
    }
}

private struct AudioArchiveResourceRow: View {
    let title: String
    let snapshot: DownloadSnapshot
    let isRunningAction: Bool
    let runAction: (SettingsViewModel.AudioResourceAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                if isRunningAction {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            Text(snapshotDescription)
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let progress = snapshot.progress {
                ProgressView(value: progress)
            }

            HStack {
                ForEach(availableActions, id: \.self) { action in
                    Button(action.buttonTitle) {
                        runAction(action)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isRunningAction)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var availableActions: [SettingsViewModel.AudioResourceAction] {
        switch snapshot.state {
        case .idle:
            return [.start]
        case .downloading:
            return [.pause, .restart]
        case .paused:
            return [.resume, .restart]
        case .completed:
            return [.restart]
        case .failed:
            return [.restart]
        }
    }

    private var snapshotDescription: String {
        let downloaded = ByteCountFormatter.string(fromByteCount: snapshot.downloadedBytes, countStyle: .file)
        let total = snapshot.totalBytes.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) } ?? "--"

        switch snapshot.state {
        case .idle:
            return "尚未下載"
        case .downloading:
            return "下載中 · \(downloaded) / \(total)"
        case .paused:
            return "已暫停 · \(downloaded) / \(total)"
        case .completed:
            return "已完成 · \(downloaded)"
        case .failed(let message):
            return "失敗 · \(message)"
        }
    }
}

private extension SettingsViewModel.AudioResourceAction {
    var buttonTitle: String {
        switch self {
        case .start:
            return "下載"
        case .pause:
            return "暫停"
        case .resume:
            return "續傳"
        case .restart:
            return "重下載"
        }
    }
}

private extension AppLocale {
    var displayName: String {
        switch self {
        case .traditionalChinese:
            return "正體中文"
        case .simplifiedChinese:
            return "简体中文"
        case .english:
            return "English"
        }
    }
}

private extension AppThemePreference {
    var displayName: String {
        switch self {
        case .system:
            return "跟隨系統"
        case .light:
            return "淺色"
        case .dark:
            return "深色"
        case .amoled:
            return "AMOLED"
        }
    }
}

private extension Double {
    var displayScaleLabel: String {
        String(format: "%.2fx", self)
    }
}
