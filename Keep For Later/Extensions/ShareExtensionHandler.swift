import Foundation
import SwiftData

@MainActor
class ShareExtensionHandler {
    let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveItem(url: String?, snippet: String?, title: String?, note: String?) throws {
        // Basic validation: at least one of url/snippet/note must be present.
        guard url != nil || snippet != nil || note != nil else {
            return
        }
        
        let item = SavedItem(
            url: url,
            title: title,
            snippet: snippet,
            note: note,
            sourceApp: nil
        )
        modelContext.insert(item)
        try modelContext.save()
    }
}
