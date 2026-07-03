import Foundation

final class TrashService {
    private let fileManager = FileManager.default

    func moveToTrash(items: [RemovableItem]) -> RemovalResult {
        var movedItems: [URL] = []
        var failedItems: [(URL, String)] = []

        for item in items {
            do {
                var resultingURL: NSURL?
                try fileManager.trashItem(at: item.url, resultingItemURL: &resultingURL)
                movedItems.append((resultingURL as URL?) ?? item.url)
            } catch {
                failedItems.append((item.url, error.localizedDescription))
            }
        }

        return RemovalResult(movedItems: movedItems, failedItems: failedItems)
    }
}
