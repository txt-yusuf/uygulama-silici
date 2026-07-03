import Foundation
import Observation

@MainActor
@Observable
final class AppCleanerViewModel {
    private let scanner = ApplicationScanner()
    private let trashService = TrashService()

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

    var canMoveSelectedItemsToTrash: Bool {
        selectedApplication?.isSystemApp == false && !selectedItems.isEmpty
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

        let moved = Set(itemsToRemove.map(\.id)).subtracting(result.failedItems.map(\.0))
        removableItems.removeAll { moved.contains($0.id) }
        selectedItemIDs.subtract(moved)

        if result.failedItems.isEmpty {
            statusMessage = localizer.format("status.moved", result.movedItems.count)
        } else {
            statusMessage = localizer.format("status.movedWithFailures", result.movedItems.count, result.failedItems.count)
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
