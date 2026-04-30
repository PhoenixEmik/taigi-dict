import XCTest
import TaigiDictCore
@testable import TaigiDictUI

@MainActor
final class WordDetailViewModelTests: XCTestCase {
    func testPrepareResolvesAliasChainBeforeDisplay() async {
        let alias = entry(id: 1, hanji: "字典", romanization: "jī-tián", aliasTargetEntryID: 2)
        let primary = entry(id: 2, hanji: "辭典", romanization: "sû-tián", definition: "工具書")
        let repository = InMemoryRepository(entries: [alias, primary])
        let viewModel = WordDetailViewModel(library: DictionaryLibrary(repository: repository))
        _ = await viewModel.prepare(entry: alias)

        XCTAssertEqual(viewModel.entry?.id, 2)
        XCTAssertEqual(viewModel.resolvedEntryID, 2)
        XCTAssertEqual(viewModel.shareText(), "辭典\nsû-tián\n工具書")
    }

    func testPrepareMarksOnlyExternalLinkedRelationshipWordsOpenable() async {
        let primary = entry(
            id: 1,
            hanji: "辭典",
            romanization: "sû-tián",
            variantChars: ["辭典"],
            wordSynonyms: ["字典", "無此詞"]
        )
        let linked = entry(id: 2, hanji: "字典", romanization: "jī-tián")
        let repository = InMemoryRepository(entries: [primary, linked])
        let viewModel = WordDetailViewModel(library: DictionaryLibrary(repository: repository))
        _ = await viewModel.prepare(entry: primary)

        XCTAssertEqual(viewModel.openableWords, ["字典"])
    }
}

private actor InMemoryRepository: DictionaryRepositoryProtocol {
    private let bundle: DictionaryBundle
    private let repository: InMemoryDictionaryRepository

    init(entries: [DictionaryEntry]) {
        bundle = DictionaryBundle(
            entryCount: entries.count,
            senseCount: entries.reduce(0) { $0 + $1.senses.count },
            exampleCount: 0,
            entries: entries
        )
        repository = InMemoryDictionaryRepository(bundle: bundle)
    }

    func loadBundle() async throws -> DictionaryBundle {
        bundle
    }

    func search(_ rawQuery: String, limit: Int, offset: Int) async throws -> [DictionaryEntry] {
        let results = await repository.search(rawQuery, limit: limit + max(offset, 0))
        return Array(results.dropFirst(max(offset, 0)))
    }

    func findLinkedEntry(_ rawWord: String) async throws -> DictionaryEntry? {
        await repository.findLinkedEntry(rawWord)
    }

    func entries(ids: [Int64]) async throws -> [DictionaryEntry] {
        await repository.entries(ids: ids)
    }

    func entry(id: Int64) async throws -> DictionaryEntry? {
        await repository.entry(id: id)
    }

    func clearBundleCache() async {}
}

private func entry(
    id: Int64,
    hanji: String,
    romanization: String,
    definition: String = "",
    variantChars: [String] = [],
    wordSynonyms: [String] = [],
    aliasTargetEntryID: Int64? = nil
) -> DictionaryEntry {
    DictionaryEntry(
        id: id,
        type: "名詞",
        hanji: hanji,
        romanization: romanization,
        category: "主詞目",
        audioID: "",
        hokkienSearch: "\(hanji) \(romanization)",
        mandarinSearch: definition,
        variantChars: variantChars,
        wordSynonyms: wordSynonyms,
        aliasTargetEntryID: aliasTargetEntryID,
        senses: [
            DictionarySense(partOfSpeech: "名詞", definition: definition),
        ]
    )
}
