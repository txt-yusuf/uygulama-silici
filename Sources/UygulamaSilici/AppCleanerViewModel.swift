import AppKit
import Foundation
import Observation

@MainActor
@Observable
final class AppCleanerViewModel {
    private let scanner = ApplicationScanner()
    private let trashService = TrashService()
    private let historyStore = RemovalHistoryStore()

    var applications: [InstalledApp] = []
    var selectedApplication: InstalledApp?
    var removableItems: [RemovableItem] = []
    var selectedItemIDs = Set<RemovableItem.ID>()
    var searchText = ""
    var isScanningApplications = false
    var isScanningItems = false
    var language: AppLanguage = .turkish {
        didSet {
            if !isScanningApplications && !isScanningItems && applications.isEmpty {
                statusMessage = localizer.text("status.initial")
            }
        }
    }
    var statusMessage = Localizer(language: .turkish).text("status.initial")
    var lastResult: RemovalResult?
    var removalHistory: [RemovalHistoryEntry] = []

    private var localizer: Localizer {
        Localizer(language: language)
    }

    var filteredApplications: [InstalledApp] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return applications
        }

        return applications.filter { app in
            app.name.localizedCaseInsensitiveContains(searchText) ||
            (app.bundleIdentifier?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var selectedItems: [RemovableItem] {
        removableItems.filter { selectedItemIDs.contains($0.id) }
    }

    var selectedSize: Int64 {
        selectedItems.reduce(0) { $0 + $1.size }
    }

    var totalRemovableSize: Int64 {
        removableItems.reduce(0) { $0 + $1.size }
    }

    var optionalItemCount: Int {
        removableItems.filter { !$0.isRequired }.count
    }

    var canMoveSelectedItemsToTrash: Bool {
        selectedApplication?.isSystemApp == false && !selectedItems.isEmpty
    }

    var latestHistoryEntry: RemovalHistoryEntry? {
        removalHistory.first
    }

    var selectedHighRiskCount: Int {
        selectedItems.filter { $0.risk == .high }.count
    }

    var selectedMediumRiskCount: Int {
        selectedItems.filter { $0.risk == .medium }.count
    }

    func revealInFinder(_ item: RemovableItem) {
        NSWorkspace.shared.activateFileViewerSelecting([item.url])
    }

    func loadHistory() {
        removalHistory = historyStore.load().sorted { $0.date > $1.date }
    }

    func refreshApplications() {
        isScanningApplications = true
        statusMessage = localizer.text("status.scanningApps")

        Task {
            let apps = await Task.detached(priority: .userInitiated) {
                ApplicationScanner().installedApplications()
            }.value

            applications = apps
            selectedApplication = selectedApplication.flatMap { selected in
                apps.first { $0.url == selected.url }
            } ?? apps.first
            isScanningApplications = false
            statusMessage = localizer.format("status.appsFound", apps.count)

            if let selectedApplication {
                scanItems(for: selectedApplication)
            }
        }
    }

    func select(_ app: InstalledApp) {
        selectedApplication = app
        removableItems = []
        selectedItemIDs = []
        lastResult = nil
        scanItems(for: app)
    }

    func scanSelectedApplication() {
        guard let selectedApplication else { return }
        scanItems(for: selectedApplication)
    }

    func toggleSelection(for item: RemovableItem) {
        if item.isRequired { return }

        if selectedItemIDs.contains(item.id) {
            selectedItemIDs.remove(item.id)
        } else {
            selectedItemIDs.insert(item.id)
        }
    }

    func selectAllOptionalItems() {
        selectedItemIDs = Set(removableItems.map(\.id))
    }

    func clearOptionalSelection() {
        selectedItemIDs = Set(removableItems.filter(\.isRequired).map(\.id))
    }

    func moveSelectedItemsToTrash() {
        let itemsToRemove = selectedItems
        guard !itemsToRemove.isEmpty else { return }

        let result = trashService.moveToTrash(items: itemsToRemove)
        lastResult = result

        if !result.movedItems.isEmpty {
            let entry = RemovalHistoryEntry(
                id: UUID(),
                appName: selectedApplication?.name ?? localizer.text("info.unknown"),
                date: Date(),
                movedItems: result.movedItems
            )
            removalHistory.insert(entry, at: 0)
            removalHistory = Array(removalHistory.prefix(20))
            historyStore.save(removalHistory)
        }

        let moved = Set(result.movedItems.map { URL(fileURLWithPath: $0.originalPath) })
        removableItems.removeAll { moved.contains($0.id) }
        selectedItemIDs.subtract(moved)

        if result.failedItems.isEmpty {
            statusMessage = localizer.format("status.moved", result.movedItems.count)
        } else {
            statusMessage = localizer.format("status.movedWithFailures", result.movedItems.count, result.failedItems.count)
        }

        refreshApplications()
    }

    func restoreLatestRemoval() {
        guard let entry = latestHistoryEntry else { return }
        let failures = historyStore.restore(entry)
        removalHistory.removeAll { $0.id == entry.id }
        historyStore.save(removalHistory)

        if failures.isEmpty {
            statusMessage = localizer.format("status.restored", entry.movedItems.count)
        } else {
            statusMessage = localizer.format("status.restoredWithFailures", entry.movedItems.count - failures.count, failures.count)
        }

        refreshApplications()
    }

    private func scanItems(for app: InstalledApp) {
        isScanningItems = true
        statusMessage = localizer.format("status.scanningItems", app.name)

        Task {
            let items = await Task.detached(priority: .userInitiated) {
                ApplicationScanner().removableItems(for: app)
            }.value

            removableItems = items
            selectedItemIDs = Set(items.map(\.id))
            isScanningItems = false
            statusMessage = localizer.format("status.itemsFound", items.count)
        }
    }
}
