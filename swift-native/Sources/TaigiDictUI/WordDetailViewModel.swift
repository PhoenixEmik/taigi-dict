import Foundation
import Observation
import TaigiDictCore

@MainActor
@Observable
public final class WordDetailViewModel {
    public private(set) var entry: DictionaryEntry?
    public private(set) var resolvedEntryID: Int64?
    public private(set) var openableWords: Set<String> = []
    public private(set) var isPreparing = false
    public private(set) var errorMessage: String?

    private let library: DictionaryLibrary

    public init(library: DictionaryLibrary) {
        self.library = library
    }

    public func prepare(entry sourceEntry: DictionaryEntry) async {
        isPreparing = true
        errorMessage = nil
        entry = nil
        resolvedEntryID = nil
        openableWords = []

        do {
            let resolvedEntry = try await resolveAliasChain(from: sourceEntry)
            entry = resolvedEntry
            resolvedEntryID = resolvedEntry.id
            openableWords = try await resolveOpenableWords(from: resolvedEntry)
        } catch {
            entry = sourceEntry
            resolvedEntryID = sourceEntry.id
            errorMessage = String(describing: error)
        }

        isPreparing = false
    }

    public func linkedEntry(for word: String) async -> DictionaryEntry? {
        guard openableWords.contains(word) else {
            return nil
        }

        return try? await library.findLinkedEntry(word)
    }

    public func shareText() -> String {
        guard let entry else {
            return ""
        }

        var lines = [
            entry.hanji,
            entry.romanization,
        ].filter { !$0.isEmpty }

        if let definition = entry.senses.first(where: { !$0.definition.isEmpty })?.definition {
            lines.append(definition)
        } else if !entry.briefSummary.isEmpty {
            lines.append(entry.briefSummary)
        }

        return lines.joined(separator: "\n")
    }

    private func resolveAliasChain(from sourceEntry: DictionaryEntry) async throws -> DictionaryEntry {
        var currentEntry = sourceEntry
        var visitedIDs = Set<Int64>()

        while let targetID = currentEntry.aliasTargetEntryID {
            guard visitedIDs.insert(currentEntry.id).inserted else {
                break
            }

            guard let targetEntry = try await library.entry(id: targetID) else {
                break
            }

            currentEntry = targetEntry
        }

        return currentEntry
    }

    private func resolveOpenableWords(from entry: DictionaryEntry) async throws -> Set<String> {
        var words = OrderedUniqueStrings()
        words.append(contentsOf: entry.variantChars)
        words.append(contentsOf: entry.wordSynonyms)
        words.append(contentsOf: entry.wordAntonyms)

        for sense in entry.senses {
            words.append(contentsOf: sense.definitionSynonyms)
            words.append(contentsOf: sense.definitionAntonyms)
        }

        var openable = Set<String>()
        for word in words.values {
            guard let linkedEntry = try await library.findLinkedEntry(word) else {
                continue
            }

            if linkedEntry.id != entry.id {
                openable.insert(word)
            }
        }

        return openable
    }
}

private struct OrderedUniqueStrings {
    private(set) var values: [String] = []
    private var seen = Set<String>()

    mutating func append(contentsOf newValues: [String]) {
        for value in newValues {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, seen.insert(trimmed).inserted else {
                continue
            }
            values.append(trimmed)
        }
    }
}
