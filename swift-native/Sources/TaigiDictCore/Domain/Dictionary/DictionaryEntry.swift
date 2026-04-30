import Foundation

public struct DictionaryEntry: Identifiable, Hashable, Sendable {
    public var id: Int64
    public var type: String
    public var hanji: String
    public var romanization: String
    public var category: String
    public var audioID: String
    public var hokkienSearch: String
    public var mandarinSearch: String
    public var variantChars: [String]
    public var wordSynonyms: [String]
    public var wordAntonyms: [String]
    public var alternativePronunciations: [String]
    public var contractedPronunciations: [String]
    public var colloquialPronunciations: [String]
    public var phoneticDifferences: [String]
    public var vocabularyComparisons: [String]
    public var aliasTargetEntryID: Int64?
    public var senses: [DictionarySense]

    public init(
        id: Int64,
        type: String,
        hanji: String,
        romanization: String,
        category: String,
        audioID: String,
        hokkienSearch: String,
        mandarinSearch: String,
        variantChars: [String] = [],
        wordSynonyms: [String] = [],
        wordAntonyms: [String] = [],
        alternativePronunciations: [String] = [],
        contractedPronunciations: [String] = [],
        colloquialPronunciations: [String] = [],
        phoneticDifferences: [String] = [],
        vocabularyComparisons: [String] = [],
        aliasTargetEntryID: Int64? = nil,
        senses: [DictionarySense] = []
    ) {
        self.id = id
        self.type = type
        self.hanji = hanji
        self.romanization = romanization
        self.category = category
        self.audioID = audioID
        self.hokkienSearch = hokkienSearch
        self.mandarinSearch = mandarinSearch
        self.variantChars = variantChars
        self.wordSynonyms = wordSynonyms
        self.wordAntonyms = wordAntonyms
        self.alternativePronunciations = alternativePronunciations
        self.contractedPronunciations = contractedPronunciations
        self.colloquialPronunciations = colloquialPronunciations
        self.phoneticDifferences = phoneticDifferences
        self.vocabularyComparisons = vocabularyComparisons
        self.aliasTargetEntryID = aliasTargetEntryID
        self.senses = senses
    }

    public var redirectsToPrimaryEntry: Bool {
        aliasTargetEntryID != nil
    }

    public var briefSummary: String {
        if redirectsToPrimaryEntry {
            return ""
        }

        if let definition = senses.first(where: { !$0.definition.isEmpty })?.definition {
            return definition
        }

        if !category.isEmpty {
            return category
        }

        if !type.isEmpty {
            return type
        }

        return romanization
    }
}
