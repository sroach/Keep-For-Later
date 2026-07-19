import XCTest
import SwiftData
@testable import Keep_For_Later

@MainActor
final class RepositoryTests: XCTestCase {
    var modelContext: ModelContext!
    var repository: SavedItemRepository!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([SavedItem.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        modelContext = container.mainContext
        repository = SavedItemRepository(modelContext: modelContext)
    }
    
    func testCreateAndFetch() throws {
        let item = SavedItem(title: "Test Item", url: "https://test.com")
        try repository.create(item)
        
        let fetched = try repository.fetchAll()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Test Item")
    }
    
    func testDeduplication() throws {
        let item1 = SavedItem(url: "https://test.com")
        let item2 = SavedItem(url: "https://test.com") // Same content, same hash
        
        try repository.create(item1)
        try repository.create(item2)
        
        let fetched = try repository.fetchAll()
        XCTAssertEqual(fetched.count, 1, "Should deduplicate by content hash")
    }
    
    func testSearch() throws {
        try repository.create(SavedItem(title: "Apple", note: "Fruit"))
        try repository.create(SavedItem(title: "Banana", note: "Fruit"))
        
        let results = try repository.search(text: "Apple")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Apple")
    }
    
    func testDelete() throws {
        let item = SavedItem(title: "To be deleted")
        try repository.create(item)
        XCTAssertEqual((try repository.fetchAll()).count, 1)
        
        try repository.delete(item)
        XCTAssertEqual((try repository.fetchAll()).count, 0)
    }
}
