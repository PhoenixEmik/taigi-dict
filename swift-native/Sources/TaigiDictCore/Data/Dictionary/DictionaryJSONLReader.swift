import Foundation

public enum DictionaryJSONLReaderError: Error, Equatable {
    case invalidUTF8
    case invalidLine(line: Int, message: String)
}

public struct DictionaryJSONLReader: Sendable {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func readEntries(from data: Data) throws -> [DictionaryEntry] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw DictionaryJSONLReaderError.invalidUTF8
        }

        var entries: [DictionaryEntry] = []

        for (offset, rawLine) in content.split(whereSeparator: \.isNewline).enumerated() {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty {
                continue
            }

            guard let lineData = line.data(using: .utf8) else {
                throw DictionaryJSONLReaderError.invalidUTF8
            }

            do {
                entries.append(try decoder.decode(DictionaryEntry.self, from: lineData))
            } catch {
                throw DictionaryJSONLReaderError.invalidLine(
                    line: offset + 1,
                    message: String(describing: error)
                )
            }
        }

        return entries
    }
}
