import Foundation
import SwiftData
import CryptoKit

@Model
final class SavedItem {
    @Attribute(.unique) var id: UUID
    var url: String?
    var title: String?
    var snippet: String?
    var note: String?
    var sourceApp: String?
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var isArchived: Bool
    var contentHash: String

    init(
        id: UUID = UUID(),
        url: String? = nil,
        title: String? = nil,
        snippet: String? = nil,
        note: String? = nil,
        sourceApp: String? = nil,
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isArchived: Bool = false,
        contentHash: String? = nil
    ) {
        self.id = id
        self.url = url
        self.title = title
        self.snippet = snippet
        self.note = note
        self.sourceApp = sourceApp
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
        self.contentHash = contentHash ?? SavedItem.generateHash(url: url, snippet: snippet, note: note)
    }

    static func generateHash(url: String?, snippet: String?, note: String?) -> String {
        let normalizedURL = url?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let normalizedSnippet = snippet?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let normalizedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        let combined = "\(normalizedURL)|\(normalizedSnippet)|\(normalizedNote)"
        let data = Data(combined.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
