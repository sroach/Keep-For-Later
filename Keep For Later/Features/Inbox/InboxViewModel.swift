import Foundation
import SwiftData
import Combine
import os

@MainActor
final class InboxViewModel: ObservableObject {
    @Published var items: [SavedItem] = []
    @Published var searchText: String = ""
    @Published var selectedTags: Set<String> = []
    
    private let repository: SavedItemRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: SavedItemRepositoryProtocol) {
        self.repository = repository
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
            
        // Listen for remote changes (e.g. from Share Extension)
        NotificationCenter.default.publisher(for: NSNotification.Name("NSPersistentStoreRemoteChangeNotification"))
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.refresh()
                }
            }
            .store(in: &cancellables)
    }

    func refresh() {
        do {
            if searchText.isEmpty {
                items = try repository.fetchAll()
            } else {
                items = try repository.search(text: searchText)
            }
            
            if !selectedTags.isEmpty {
                items = items.filter { item in
                    !selectedTags.isDisjoint(with: Set(item.tags))
                }
            }
        } catch {
            Logger.ui.error("Failed to fetch items: \(error.localizedDescription)")
        }
    }

    func delete(item: SavedItem) {
        do {
            try repository.delete(item)
            refresh()
        } catch {
            Logger.ui.error("Failed to delete item: \(error.localizedDescription)")
        }
    }

    func archive(item: SavedItem) {
        do {
            try repository.archive(item)
            refresh()
        } catch {
            Logger.ui.error("Failed to archive item: \(error.localizedDescription)")
        }
    }
    
    func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
        refresh()
    }
    
    var allTags: [String] {
        // This is a bit expensive to compute every time, but for MVP it's fine.
        // In a real app we might want to cache this or use a separate Tag entity.
        let tags = items.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
}
