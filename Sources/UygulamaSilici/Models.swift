import AppKit
import Foundation

struct InstalledApp: Identifiable, Hashable {
    let id: URL
    let name: String
    let url: URL
    let bundleIdentifier: String?
    let version: String?
    let executableName: String?
    let packageName: String
    let category: String?
    let size: Int64
    let creationDate: Date?
    let modificationDate: Date?
    let isSystemApp: Bool

    var icon: NSImage {
        NSWorkspace.shared.icon(forFile: url.path)
    }
}

struct RemovableItem: Identifiable, Hashable {
    enum Risk: String, Codable {
        case low
        case medium
        case high
    }

    enum Kind: String {
        case application = "Uygulama"
        case support = "Destek dosyası"
        case cache = "Önbellek"
        case preferences = "Tercihler"
        case logs = "Günlük"
        case container = "Kapsayıcı"
        case launchAgent = "Başlatma öğesi"
        case privilegedHelper = "Yardımcı servis"
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

    var risk: Risk {
        if isRequired || kind == .application || kind == .privilegedHelper {
            return .high
        }

        if path.hasPrefix("/Library/") || kind == .launchAgent || kind == .container || kind == .preferences {
            return .medium
        }

        return .low
    }
}

struct RemovalResult {
    let movedItems: [MovedTrashItem]
    let failedItems: [(URL, String)]
}

struct MovedTrashItem: Codable, Hashable, Identifiable {
    var id: String { originalPath }
    let originalPath: String
    let trashedPath: String
    let displayName: String
    let kind: String
    let size: Int64
}

struct RemovalHistoryEntry: Codable, Identifiable, Hashable {
    let id: UUID
    let appName: String
    let date: Date
    let movedItems: [MovedTrashItem]

    var totalSize: Int64 {
        movedItems.reduce(0) { $0 + $1.size }
    }
}

extension Int64 {
    var formattedFileSize: String {
        ByteCountFormatter.string(fromByteCount: self, countStyle: .file)
    }
}
