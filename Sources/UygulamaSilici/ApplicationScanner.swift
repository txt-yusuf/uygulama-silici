import Foundation

final class ApplicationScanner {
    private let fileManager = FileManager.default

    func installedApplications() -> [InstalledApp] {
        let applicationFolders = [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true)
        ]

        var apps: [InstalledApp] = []
        var seen = Set<URL>()

        for folder in applicationFolders {
            guard let urls = try? fileManager.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: [.isApplicationKey, .isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }

            for url in urls where url.pathExtension == "app" && !seen.contains(url) {
                seen.insert(url)
                apps.append(makeInstalledApp(from: url))
            }
        }

        return apps.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
    }

    func removableItems(for app: InstalledApp) -> [RemovableItem] {
        var items: [RemovableItem] = [
            RemovableItem(
                url: app.url,
                kind: .application,
                size: sizeOfItem(at: app.url, skipsPackageDescendants: false),
                isRequired: true
            )
        ]

        let identifiers = searchTokens(for: app)
        guard !identifiers.isEmpty else { return items }

        for location in searchableLocations() {
            items.append(contentsOf: matchingChildren(in: location.url, kind: location.kind, tokens: identifiers))
        }

        var seen = Set<URL>()
        return items.filter { item in
            guard !seen.contains(item.url) else { return false }
            seen.insert(item.url)
            return true
        }
        .sorted { lhs, rhs in
            if lhs.kind == .application { return true }
            if rhs.kind == .application { return false }
            return lhs.path.localizedCaseInsensitiveCompare(rhs.path) == .orderedAscending
        }
    }

    private func makeInstalledApp(from url: URL) -> InstalledApp {
        let bundle = Bundle(url: url)
        let info = bundle?.infoDictionary
        let name = (info?["CFBundleDisplayName"] as? String)
            ?? (info?["CFBundleName"] as? String)
            ?? url.deletingPathExtension().lastPathComponent
        let version = (info?["CFBundleShortVersionString"] as? String)
            ?? (info?["CFBundleVersion"] as? String)
        let packageName = url.deletingPathExtension().lastPathComponent
        let executableName = info?["CFBundleExecutable"] as? String
        let category = info?["LSApplicationCategoryType"] as? String
        let values = try? url.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
        let isSystemApp = url.path.hasPrefix("/System/") || url.path.hasPrefix("/Applications/Utilities/")

        return InstalledApp(
            id: url,
            name: name,
            url: url,
            bundleIdentifier: bundle?.bundleIdentifier,
            version: version,
            executableName: executableName,
            packageName: packageName,
            category: category,
            size: sizeOfItem(at: url, skipsPackageDescendants: false),
            creationDate: values?.creationDate,
            modificationDate: values?.contentModificationDate,
            isSystemApp: isSystemApp
        )
    }

    private func searchTokens(for app: InstalledApp) -> Set<String> {
        var tokens = Set<String>()
        if let bundleIdentifier = app.bundleIdentifier, !bundleIdentifier.isEmpty {
            insertToken(bundleIdentifier, into: &tokens)
            bundleIdentifier
                .split(separator: ".")
                .map(String.init)
                .filter { $0.count >= 3 && !["com", "org", "net", "app"].contains($0.lowercased()) }
                .forEach { insertToken($0, into: &tokens) }
        }

        [
            app.name,
            app.packageName,
            app.executableName
        ]
        .compactMap { $0 }
        .forEach { insertToken($0, into: &tokens) }

        if let bundleName = Bundle(url: app.url)?.object(forInfoDictionaryKey: "CFBundleName") as? String {
            insertToken(bundleName, into: &tokens)
        }

        return tokens
    }

    private func insertToken(_ value: String, into tokens: inout Set<String>) {
        let normalized = value
            .replacingOccurrences(of: ".app", with: "")
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalized.count >= 3 else { return }
        tokens.insert(normalized)
        tokens.insert(normalized.replacingOccurrences(of: " ", with: ""))
        tokens.insert(normalized.replacingOccurrences(of: " ", with: "-"))
        tokens.insert(normalized.replacingOccurrences(of: "_", with: "-"))
    }

    private func searchableLocations() -> [(url: URL, kind: RemovableItem.Kind)] {
        let library = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Library", isDirectory: true)
        let systemLibrary = URL(fileURLWithPath: "/Library", isDirectory: true)

        return [
            (library.appendingPathComponent("Application Support", isDirectory: true), .support),
            (library.appendingPathComponent("Caches", isDirectory: true), .cache),
            (library.appendingPathComponent("Preferences", isDirectory: true), .preferences),
            (library.appendingPathComponent("Logs", isDirectory: true), .logs),
            (library.appendingPathComponent("Containers", isDirectory: true), .container),
            (library.appendingPathComponent("Group Containers", isDirectory: true), .container),
            (library.appendingPathComponent("Saved Application State", isDirectory: true), .other),
            (library.appendingPathComponent("HTTPStorages", isDirectory: true), .cache),
            (library.appendingPathComponent("LaunchAgents", isDirectory: true), .launchAgent),
            (library.appendingPathComponent("Application Scripts", isDirectory: true), .support),
            (library.appendingPathComponent("WebKit", isDirectory: true), .cache),
            (library.appendingPathComponent("Cookies", isDirectory: true), .cache),
            (library.appendingPathComponent("Preferences/ByHost", isDirectory: true), .preferences),
            (systemLibrary.appendingPathComponent("Application Support", isDirectory: true), .support),
            (systemLibrary.appendingPathComponent("Caches", isDirectory: true), .cache),
            (systemLibrary.appendingPathComponent("Preferences", isDirectory: true), .preferences),
            (systemLibrary.appendingPathComponent("Logs", isDirectory: true), .logs),
            (systemLibrary.appendingPathComponent("LaunchAgents", isDirectory: true), .launchAgent),
            (systemLibrary.appendingPathComponent("LaunchDaemons", isDirectory: true), .launchAgent),
            (systemLibrary.appendingPathComponent("PrivilegedHelperTools", isDirectory: true), .privilegedHelper)
        ]
    }

    private func matchingChildren(in folder: URL, kind: RemovableItem.Kind, tokens: Set<String>) -> [RemovableItem] {
        guard let children = try? fileManager.contentsOfDirectory(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .totalFileAllocatedSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        let directMatches: [RemovableItem] = children.compactMap { child in
            let candidate = child.lastPathComponent.lowercased()
            let matches = tokens.contains { token in
                candidate == token ||
                candidate.contains(token) ||
                token.contains(candidate) && candidate.count >= 4
            }

            guard matches else { return nil }
            return RemovableItem(
                url: child,
                kind: kind,
                size: sizeOfItem(at: child),
                isRequired: false
            )
        }

        let nestedMatches = nestedMatchingChildren(in: folder, kind: kind, tokens: tokens, directChildren: children)
        return directMatches + nestedMatches
    }

    private func nestedMatchingChildren(
        in folder: URL,
        kind: RemovableItem.Kind,
        tokens: Set<String>,
        directChildren: [URL]
    ) -> [RemovableItem] {
        let containers = directChildren.filter { child in
            let name = child.lastPathComponent.lowercased()
            return name == "com.apple.sharedfilelist" ||
                name == "byhost" ||
                name == "saved application state"
        }

        return containers.flatMap { container in
            guard let children = try? fileManager.contentsOfDirectory(
                at: container,
                includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .totalFileAllocatedSizeKey],
                options: [.skipsHiddenFiles]
            ) else { return [RemovableItem]() }

            return children.compactMap { child in
                let candidate = child.lastPathComponent.lowercased()
                let matches = tokens.contains { token in
                    candidate == token ||
                    candidate.contains(token) ||
                    token.contains(candidate) && candidate.count >= 4
                }

                guard matches else { return nil }
                return RemovableItem(
                    url: child,
                    kind: kind,
                    size: sizeOfItem(at: child),
                    isRequired: false
                )
            }
        }
    }

    private func sizeOfItem(at url: URL, skipsPackageDescendants: Bool = true) -> Int64 {
        var options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
        if skipsPackageDescendants {
            options.insert(.skipsPackageDescendants)
        }

        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            options: options
        ) else {
            return fileSize(at: url)
        }

        var total: Int64 = fileSize(at: url)
        for case let fileURL as URL in enumerator {
            total += fileSize(at: fileURL)
        }
        return total
    }

    private func fileSize(at url: URL) -> Int64 {
        let values = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
        return Int64(values?.totalFileAllocatedSize ?? values?.fileAllocatedSize ?? 0)
    }
}
