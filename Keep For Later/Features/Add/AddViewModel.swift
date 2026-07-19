import Foundation
import SwiftData
import Combine
import UIKit
import os

@MainActor
final class AddViewModel: ObservableObject {
    @Published var url: String = ""
    @Published var title: String = ""
    @Published var snippet: String = ""
    @Published var note: String = ""
    @Published var tagsString: String = ""
    
    @Published var showPasteButton: Bool = false
    
    private let repository: SavedItemRepositoryProtocol
    
    init(repository: SavedItemRepositoryProtocol) {
        self.repository = repository
        checkClipboard()
    }
    
    func checkClipboard() {
        if let content = UIPasteboard.general.string, !content.isEmpty {
            showPasteButton = true
        } else {
            showPasteButton = false
        }
    }
    
    func pasteFromClipboard() {
        if let content = UIPasteboard.general.string {
            if content.lowercased().hasPrefix("http") {
                url = content
            } else if snippet.isEmpty {
                snippet = content
            } else {
                note = content
            }
        }
    }
    
    var isSaveDisabled: Bool {
        url.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        snippet.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func save() -> Bool {
        let tags = tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let item = SavedItem(
            url: url.isEmpty ? nil : url,
            title: title.isEmpty ? nil : title,
            snippet: snippet.isEmpty ? nil : snippet,
            note: note.isEmpty ? nil : note,
            tags: tags
        )
        
        do {
            try repository.create(item)
            return true
        } catch {
            Logger.ui.error("Failed to save item: \(error.localizedDescription)")
            return false
        }
    }
}
