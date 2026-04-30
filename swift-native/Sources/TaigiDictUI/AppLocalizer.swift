import Foundation
import SwiftUI
import TaigiDictCore

enum AppLocalizedStringKey {
    case dictionaryTitle
    case searchPrompt
    case loadingDictionary
    case loadingFailedTitle
    case searching
    case noResultTitle
    case noResultDescription
    case searchResultsSection
    case searchStartTitle
    case searchStartDescription
    case searchHistoryTitle
    case clearSearchHistory
    case detailLoading
    case detailLoadFailedTitle
    case playWordAudio
    case playExampleAudio
    case audioSectionTitle
    case noAudioAvailable
    case audioNotInitialized
    case audioPlaying
    case audioStopped
    case searchStartDetailTitle
    case searchStartDetailDescription
    case bookmarksAdd
    case bookmarksRemove
    case share
    case relationshipsVariant
    case relationshipsSynonym
    case relationshipsAntonym
    case definitionFallbackTitle
    case definitionSynonym
    case definitionAntonym
}

enum AppLocalizer {
    static func text(_ key: AppLocalizedStringKey, locale: AppLocale) -> String {
        switch locale {
        case .traditionalChinese:
            return traditionalChinese(key)
        case .simplifiedChinese:
            return simplifiedChinese(key)
        case .english:
            return english(key)
        }
    }

    static func appLocale(from locale: Locale) -> AppLocale {
        let identifier = locale.identifier.lowercased()
        if identifier.hasPrefix("zh-cn") || identifier.hasPrefix("zh-hans") {
            return .simplifiedChinese
        }
        if identifier.hasPrefix("zh") {
            return .traditionalChinese
        }
        return .english
    }

    private static func traditionalChinese(_ key: AppLocalizedStringKey) -> String {
        switch key {
        case .dictionaryTitle: return "辭典"
        case .searchPrompt: return "輸入台語漢字、白話字或華語詞義"
        case .loadingDictionary: return "載入辭典資料中"
        case .loadingFailedTitle: return "載入失敗"
        case .searching: return "搜尋中"
        case .noResultTitle: return "查無結果"
        case .noResultDescription: return "試試改用漢字、羅馬字或華語詞義。"
        case .searchResultsSection: return "搜尋結果"
        case .searchStartTitle: return "開始搜尋"
        case .searchStartDescription: return "輸入台語漢字、白話字，或華語釋義後才顯示詞條。"
        case .searchHistoryTitle: return "搜尋紀錄"
        case .clearSearchHistory: return "清除搜尋紀錄"
        case .detailLoading: return "準備詞條內容"
        case .detailLoadFailedTitle: return "詞條載入失敗"
        case .playWordAudio: return "播放詞目音檔"
        case .playExampleAudio: return "播放例句音檔"
        case .audioSectionTitle: return "音訊"
        case .noAudioAvailable: return "此筆資料沒有可播放的音檔。"
        case .audioNotInitialized: return "離線音訊尚未初始化。"
        case .audioPlaying: return "播放中"
        case .audioStopped: return "已停止播放"
        case .searchStartDetailTitle: return "開始搜尋"
        case .searchStartDetailDescription: return "選擇搜尋結果後，詞條內容會顯示在這裡。"
        case .bookmarksAdd: return "加入書籤"
        case .bookmarksRemove: return "移除書籤"
        case .share: return "分享"
        case .relationshipsVariant: return "異用字"
        case .relationshipsSynonym: return "近義詞"
        case .relationshipsAntonym: return "反義詞"
        case .definitionFallbackTitle: return "解說"
        case .definitionSynonym: return "近義"
        case .definitionAntonym: return "反義"
        }
    }

    private static func simplifiedChinese(_ key: AppLocalizedStringKey) -> String {
        switch key {
        case .dictionaryTitle: return "辞典"
        case .searchPrompt: return "输入台语汉字、白话字或华语词义"
        case .loadingDictionary: return "加载辞典资料中"
        case .loadingFailedTitle: return "加载失败"
        case .searching: return "搜索中"
        case .noResultTitle: return "查无结果"
        case .noResultDescription: return "试试改用汉字、罗马字或华语词义。"
        case .searchResultsSection: return "搜索结果"
        case .searchStartTitle: return "开始搜索"
        case .searchStartDescription: return "输入台语汉字、白话字，或华语释义后才显示词条。"
        case .searchHistoryTitle: return "搜索纪录"
        case .clearSearchHistory: return "清除搜索纪录"
        case .detailLoading: return "准备词条内容"
        case .detailLoadFailedTitle: return "词条载入失败"
        case .playWordAudio: return "播放词目音档"
        case .playExampleAudio: return "播放例句音档"
        case .audioSectionTitle: return "音讯"
        case .noAudioAvailable: return "此笔资料没有可播放的音档。"
        case .audioNotInitialized: return "离线音讯尚未初始化。"
        case .audioPlaying: return "播放中"
        case .audioStopped: return "已停止播放"
        case .searchStartDetailTitle: return "开始搜索"
        case .searchStartDetailDescription: return "选择搜索结果后，词条内容会显示在这里。"
        case .bookmarksAdd: return "加入书签"
        case .bookmarksRemove: return "移除书签"
        case .share: return "分享"
        case .relationshipsVariant: return "异用字"
        case .relationshipsSynonym: return "近义词"
        case .relationshipsAntonym: return "反义词"
        case .definitionFallbackTitle: return "解说"
        case .definitionSynonym: return "近义"
        case .definitionAntonym: return "反义"
        }
    }

    private static func english(_ key: AppLocalizedStringKey) -> String {
        switch key {
        case .dictionaryTitle: return "Dictionary"
        case .searchPrompt: return "Search Taiwanese Hanji, romanization, or Mandarin meaning"
        case .loadingDictionary: return "Loading dictionary"
        case .loadingFailedTitle: return "Load failed"
        case .searching: return "Searching"
        case .noResultTitle: return "No results"
        case .noResultDescription: return "Try Hanji, romanization, or Mandarin meanings."
        case .searchResultsSection: return "Results"
        case .searchStartTitle: return "Start searching"
        case .searchStartDescription: return "Type Hanji, romanization, or Mandarin meaning to see entries."
        case .searchHistoryTitle: return "Search history"
        case .clearSearchHistory: return "Clear search history"
        case .detailLoading: return "Preparing entry"
        case .detailLoadFailedTitle: return "Failed to load entry"
        case .playWordAudio: return "Play word audio"
        case .playExampleAudio: return "Play example audio"
        case .audioSectionTitle: return "Audio"
        case .noAudioAvailable: return "No playable audio for this item."
        case .audioNotInitialized: return "Offline audio is not initialized yet."
        case .audioPlaying: return "Playing"
        case .audioStopped: return "Stopped"
        case .searchStartDetailTitle: return "Start searching"
        case .searchStartDetailDescription: return "Select a search result to view details here."
        case .bookmarksAdd: return "Add bookmark"
        case .bookmarksRemove: return "Remove bookmark"
        case .share: return "Share"
        case .relationshipsVariant: return "Variants"
        case .relationshipsSynonym: return "Synonyms"
        case .relationshipsAntonym: return "Antonyms"
        case .definitionFallbackTitle: return "Definition"
        case .definitionSynonym: return "Synonyms"
        case .definitionAntonym: return "Antonyms"
        }
    }
}
