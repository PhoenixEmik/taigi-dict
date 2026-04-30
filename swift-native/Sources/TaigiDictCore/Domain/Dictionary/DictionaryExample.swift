import Foundation

public struct DictionaryExample: Hashable, Sendable {
    public var hanji: String
    public var romanization: String
    public var mandarin: String
    public var audioID: String

    public init(
        hanji: String,
        romanization: String,
        mandarin: String,
        audioID: String
    ) {
        self.hanji = hanji
        self.romanization = romanization
        self.mandarin = mandarin
        self.audioID = audioID
    }
}
