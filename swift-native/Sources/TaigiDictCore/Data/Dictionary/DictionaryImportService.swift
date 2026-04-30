import Foundation

public enum DictionaryImportError: Error, Equatable {
    case unsupportedSchemaVersion(Int)
    case entryCountMismatch(expected: Int, actual: Int)
    case senseCountMismatch(expected: Int, actual: Int)
    case exampleCountMismatch(expected: Int, actual: Int)
}

public struct DictionaryImportService: Sendable {
    public static let supportedSchemaVersion = 1

    private let reader: DictionaryJSONLReader

    public init(reader: DictionaryJSONLReader = DictionaryJSONLReader()) {
        self.reader = reader
    }

    public func importBundle(manifest: DictionaryManifest, entriesData: Data) throws -> DictionaryBundle {
        guard manifest.schemaVersion == Self.supportedSchemaVersion else {
            throw DictionaryImportError.unsupportedSchemaVersion(manifest.schemaVersion)
        }

        let entries = try reader.readEntries(from: entriesData)
        let senseCount = entries.reduce(0) { $0 + $1.senses.count }
        let exampleCount = entries.reduce(0) { partial, entry in
            partial + entry.senses.reduce(0) { $0 + $1.examples.count }
        }

        guard entries.count == manifest.entryCount else {
            throw DictionaryImportError.entryCountMismatch(
                expected: manifest.entryCount,
                actual: entries.count
            )
        }

        guard senseCount == manifest.senseCount else {
            throw DictionaryImportError.senseCountMismatch(
                expected: manifest.senseCount,
                actual: senseCount
            )
        }

        guard exampleCount == manifest.exampleCount else {
            throw DictionaryImportError.exampleCountMismatch(
                expected: manifest.exampleCount,
                actual: exampleCount
            )
        }

        return DictionaryBundle(
            entryCount: manifest.entryCount,
            senseCount: manifest.senseCount,
            exampleCount: manifest.exampleCount,
            entries: entries
        )
    }
}
