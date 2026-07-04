import Foundation

final class RemovalHistoryStore {
    private let fileManager = FileManager.default

    private var historyURL: URL {
        let folder = fileManager
            .homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/UygulamaSilici", isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("removal-history.json")
    }

    func load() -> [RemovalHistoryEntry] {
        guard let data = try? Data(contentsOf: historyURL) else { return [] }
        return (try? JSONDecoder().decode([RemovalHistoryEntry].self, from: data)) ?? []
    }

    func save(_ entries: [RemovalHistoryEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: historyURL, options: [.atomic])
    }

    func restore(_ entry: RemovalHistoryEntry) -> [String] {
        var failures: [String] = []

        for item in entry.movedItems {
            let trashedURL = URL(fileURLWithPath: item.trashedPath)
            let originalURL = URL(fileURLWithPath: item.originalPath)

            guard fileManager.fileExists(atPath: trashedURL.path) else {
                failures.append(item.displayName)
                continue
            }

            do {
                let parent = originalURL.deletingLastPathComponent()
                try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
                if fileManager.fileExists(atPath: originalURL.path) {
                    failures.append(item.displayName)
                } else {
                    try fileManager.moveItem(at: trashedURL, to: originalURL)
                }
            } catch {
                failures.append(item.displayName)
            }
        }

        return failures
    }
}
