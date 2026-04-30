import Foundation

public protocol ResumableDownloading: Sendable {
    func startDownload(id: String, from remoteURL: URL, to localURL: URL) async
    func pauseDownload(id: String) async
    func resumeDownload(id: String) async
    func restartDownload(id: String, from remoteURL: URL, to localURL: URL) async
    func snapshot(for id: String) async -> DownloadSnapshot
}

public actor ResumableDownloadService: ResumableDownloading {
    private struct DownloadJob {
        var remoteURL: URL
        var localURL: URL
        var task: Task<Void, Never>?
    }

    private let fileManager: FileManager
    private let session: URLSession
    private var jobs: [String: DownloadJob] = [:]
    private var snapshots: [String: DownloadSnapshot] = [:]

    public init(session: URLSession = .shared, fileManager: FileManager = .default) {
        self.session = session
        self.fileManager = fileManager
    }

    public func startDownload(id: String, from remoteURL: URL, to localURL: URL) async {
        if snapshots[id]?.state == .downloading {
            return
        }

        upsertJob(id: id, remoteURL: remoteURL, localURL: localURL)
        beginDownload(id: id, restart: false)
    }

    public func pauseDownload(id: String) async {
        guard var job = jobs[id] else {
            return
        }

        job.task?.cancel()
        job.task = nil
        jobs[id] = job

        var snapshot = snapshots[id] ?? DownloadSnapshot()
        if snapshot.state == .downloading {
            snapshot.state = .paused
        }
        snapshots[id] = snapshot
    }

    public func resumeDownload(id: String) async {
        guard jobs[id] != nil else {
            return
        }

        beginDownload(id: id, restart: false)
    }

    public func restartDownload(id: String, from remoteURL: URL, to localURL: URL) async {
        await pauseDownload(id: id)
        try? fileManager.removeItem(at: localURL)

        snapshots[id] = DownloadSnapshot(state: .idle, downloadedBytes: 0, totalBytes: nil)
        upsertJob(id: id, remoteURL: remoteURL, localURL: localURL)
        beginDownload(id: id, restart: true)
    }

    public func snapshot(for id: String) async -> DownloadSnapshot {
        snapshots[id] ?? DownloadSnapshot()
    }

    private func upsertJob(id: String, remoteURL: URL, localURL: URL) {
        var existing = jobs[id]
        existing?.task?.cancel()
        jobs[id] = DownloadJob(remoteURL: remoteURL, localURL: localURL, task: nil)
    }

    private func beginDownload(id: String, restart: Bool) {
        guard var job = jobs[id] else {
            return
        }

        job.task?.cancel()
        job.task = Task { [weak self] in
            await self?.runDownload(id: id)
        }
        jobs[id] = job

        var snapshot = snapshots[id] ?? DownloadSnapshot()
        if restart {
            snapshot.downloadedBytes = 0
            snapshot.totalBytes = nil
        }
        snapshot.state = .downloading
        snapshots[id] = snapshot
    }

    private func runDownload(id: String) async {
        guard let job = jobs[id] else {
            return
        }

        do {
            try ensureParentDirectory(for: job.localURL)

            let existingBytes = fileSize(of: job.localURL)
            var request = URLRequest(url: job.remoteURL)
            if existingBytes > 0 {
                request.setValue("bytes=\(existingBytes)-", forHTTPHeaderField: "Range")
            }

            let (bytes, response) = try await session.bytes(for: request)
            let appendedTotal = resolveTotalBytes(response: response, currentSize: existingBytes)

            var snapshot = snapshots[id] ?? DownloadSnapshot()
            snapshot.state = .downloading
            snapshot.downloadedBytes = existingBytes
            snapshot.totalBytes = appendedTotal
            snapshots[id] = snapshot

            let handle: FileHandle
            if fileManager.fileExists(atPath: job.localURL.path) {
                handle = try FileHandle(forWritingTo: job.localURL)
                try handle.seekToEnd()
            } else {
                fileManager.createFile(atPath: job.localURL.path, contents: nil)
                handle = try FileHandle(forWritingTo: job.localURL)
            }

            defer {
                try? handle.close()
            }

            for try await chunk in bytes {
                try Task.checkCancellation()
                try handle.write(contentsOf: Data([chunk]))

                var rolling = snapshots[id] ?? DownloadSnapshot(state: .downloading)
                rolling.downloadedBytes += 1
                snapshots[id] = rolling
            }

            var completed = snapshots[id] ?? DownloadSnapshot()
            completed.state = .completed
            snapshots[id] = completed

            var finishedJob = jobs[id]
            finishedJob?.task = nil
            if let finishedJob {
                jobs[id] = finishedJob
            }
        } catch is CancellationError {
            // pause/restart manages state updates.
        } catch {
            var failed = snapshots[id] ?? DownloadSnapshot()
            failed.state = .failed(error.localizedDescription)
            snapshots[id] = failed

            var failedJob = jobs[id]
            failedJob?.task = nil
            if let failedJob {
                jobs[id] = failedJob
            }
        }
    }

    private func ensureParentDirectory(for fileURL: URL) throws {
        let directory = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func fileSize(of fileURL: URL) -> Int64 {
        guard
            let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
            let fileSize = values.fileSize
        else {
            return 0
        }

        return Int64(fileSize)
    }

    private func resolveTotalBytes(response: URLResponse, currentSize: Int64) -> Int64? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }

        if let contentRange = httpResponse.value(forHTTPHeaderField: "Content-Range"),
           let totalPart = contentRange.split(separator: "/").last,
           let total = Int64(totalPart) {
            return total
        }

        if response.expectedContentLength > 0 {
            return currentSize + response.expectedContentLength
        }

        return nil
    }
}
