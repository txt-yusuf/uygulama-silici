import Foundation

final class TrashService {
    private let fileManager = FileManager.default

    func moveToTrash(items: [RemovableItem]) -> RemovalResult {
        var movedItems: [MovedTrashItem] = []
        var failedItems: [(URL, String)] = []

        for item in items {
            do {
                var resultingURL: NSURL?
                try fileManager.trashItem(at: item.url, resultingItemURL: &resultingURL)
                movedItems.append(
                    MovedTrashItem(
                        originalPath: item.url.path,
                        trashedPath: ((resultingURL as URL?) ?? item.url).path,
                        displayName: item.displayName,
                        kind: item.kind.rawValue,
                        size: item.size
                    )
                )
            } catch {
                failedItems.append((item.url, error.localizedDescription))
            }
        }

        return RemovalResult(movedItems: movedItems, failedItems: failedItems)
    }
}
