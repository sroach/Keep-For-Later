import Foundation
import SwiftData

protocol SavedItemRepositoryProtocol {
    func fetchAll() throws -> [SavedItem]
    func search(text: String) throws -> [SavedItem]
    func create(_ item: SavedItem) throws
    func update(_ item: SavedItem) throws
    func delete(_ item: SavedItem) throws
    func archive(_ item: SavedItem) throws
    func unarchive(_ item: SavedItem) throws
    func findByHash(_ hash: String) throws -> SavedItem?
}

@MainActor
final class SavedItemRepository: SavedItemRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll() throws -> [SavedItem] {
        let descriptor = FetchDescriptor<SavedItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }

    func search(text: String) throws -> [SavedItem] {
        // Fetching all and filtering in memory to avoid SwiftData #Predicate complexity issues in MVP.
        let all = try fetchAll()
        return all.filter { item in
            (item.title?.localizedStandardContains(text) == true) ||
            (item.url?.localizedStandardContains(text) == true) ||
            (item.snippet?.localizedStandardContains(text) == true) ||
            (item.note?.localizedStandardContains(text) == true) ||
            item.tags.contains(where: { $0.localizedStandardContains(text) })
        }
    }

    func create(_ item: SavedItem) throws {
        if let _ = try findByHash(item.contentHash) {
            return 
        }
        modelContext.insert(item)
        try modelContext.save()
    }

    func update(_ item: SavedItem) throws {
        item.updatedAt = Date()
        item.contentHash = SavedItem.generateHash(url: item.url, snippet: item.snippet, note: item.note)
        try modelContext.save()
    }

    func delete(_ item: SavedItem) throws {
        modelContext.delete(item)
        try modelContext.save()
    }

    func archive(_ item: SavedItem) throws {
        item.isArchived = true
        item.updatedAt = Date()
        try modelContext.save()
    }

    func unarchive(_ item: SavedItem) throws {
        item.isArchived = false
        item.updatedAt = Date()
        try modelContext.save()
    }

    func findByHash(_ hash: String) throws -> SavedItem? {
        let descriptor = FetchDescriptor<SavedItem>(
            predicate: #Predicate<SavedItem> { item in
                item.contentHash == hash
            }
        )
        return try modelContext.fetch(descriptor).first
    }
}
