import Foundation

struct SavedItemDTO: Codable {
    let id: UUID
    let url: String?
    let title: String?
    let snippet: String?
    let note: String?
    let sourceApp: String?
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date
    let isArchived: Bool
    let contentHash: String
    
    init(from model: SavedItem) {
        self.id = model.id
        self.url = model.url
        self.title = model.title
        self.snippet = model.snippet
        self.note = model.note
        self.sourceApp = model.sourceApp
        self.tags = model.tags
        self.createdAt = model.createdAt
        self.updatedAt = model.updatedAt
        self.isArchived = model.isArchived
        self.contentHash = model.contentHash
    }
    
    func toModel() -> SavedItem {
        SavedItem(
            id: id,
            url: url,
            title: title,
            snippet: snippet,
            note: note,
            sourceApp: sourceApp,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived,
            contentHash: contentHash
        )
    }
}
