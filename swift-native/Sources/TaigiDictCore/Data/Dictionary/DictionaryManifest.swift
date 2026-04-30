import Foundation

public struct DictionaryManifest: Codable, Equatable, Sendable {
    public var schemaVersion: Int
    public var builtAt: String
    public var sourceModifiedAt: String?
    public var entryCount: Int
    public var senseCount: Int
    public var exampleCount: Int
    public var entriesFileName: String
    public var checksumSHA256: String?

    public init(
        schemaVersion: Int,
        builtAt: String,
        sourceModifiedAt: String? = nil,
        entryCount: Int,
        senseCount: Int,
        exampleCount: Int,
        entriesFileName: String = "dictionary_entries.jsonl",
        checksumSHA256: String? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.builtAt = builtAt
        self.sourceModifiedAt = sourceModifiedAt
        self.entryCount = entryCount
        self.senseCount = senseCount
        self.exampleCount = exampleCount
        self.entriesFileName = entriesFileName
        self.checksumSHA256 = checksumSHA256
    }
}
