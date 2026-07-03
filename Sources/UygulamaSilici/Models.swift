import AppKit
import Foundation

struct InstalledApp: Identifiable, Hashable {
    let id: URL
    let name: String
    let url: URL
    let bundleIdentifier: String?
    let version: String?
    let isSystemApp: Bool

    var icon: NSImage {
        NSWorkspace.shared.icon(forFile: url.path)
    }
}

struct RemovableItem: Identifiable, Hashable {
    enum Kind: String {
        case application = "Uygulama"
        case support = "Destek dosyası"
        case cache = "Önbellek"
        case preferences = "Tercihler"
        case logs = "Günlük"
        case container = "Kapsayıcı"
        case launchAgent = "Başlatma öğesi"
        case other = "Diğer"
    }

    let url: URL
    let kind: Kind
    let size: Int64
    let isRequired: Bool

    var id: URL {
        url
    }

    var displayName: String {
        url.lastPathComponent
    }

    var path: String {
        url.path
    }
}

struct RemovalResult {
    let movedItems: [URL]
    let failedItems: [(URL, String)]
}

extension Int64 {
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}
