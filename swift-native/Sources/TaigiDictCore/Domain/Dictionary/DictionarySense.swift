import Foundation

public struct DictionarySense: Hashable, Sendable {
    public var partOfSpeech: String
    public var definition: String
    public var definitionSynonyms: [String]
    public var definitionAntonyms: [String]
    public var examples: [DictionaryExample]

    public init(
        partOfSpeech: String,
        definition: String,
        definitionSynonyms: [String] = [],
        definitionAntonyms: [String] = [],
        examples: [DictionaryExample] = []
    ) {
        self.partOfSpeech = partOfSpeech
        self.definition = definition
        self.definitionSynonyms = definitionSynonyms
        self.definitionAntonyms = definitionAntonyms
        self.examples = examples
    }
}
