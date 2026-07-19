import XCTest
@testable import Keep_For_Later

final class SavedItemTests: XCTestCase {
    func testContentHashDeterminism() {
        let url = "https://example.com"
        let snippet = "Some snippet"
        let note = "My note"
        
        let hash1 = SavedItem.generateHash(url: url, snippet: snippet, note: note)
        let hash2 = SavedItem.generateHash(url: url, snippet: snippet, note: note)
        
        XCTAssertEqual(hash1, hash2, "Hashes should be identical for the same content")
    }
    
    func testContentHashNormalization() {
        let url1 = "https://EXAMPLE.com  "
        let url2 = "https://example.com"
        
        let hash1 = SavedItem.generateHash(url: url1, snippet: nil, note: nil)
        let hash2 = SavedItem.generateHash(url: url2, snippet: nil, note: nil)
        
        XCTAssertEqual(hash1, hash2, "Hashes should be identical after normalization")
    }
    
    func testContentHashDifferentiation() {
        let hash1 = SavedItem.generateHash(url: "a", snippet: "b", note: "c")
        let hash2 = SavedItem.generateHash(url: "a", snippet: "b", note: "d")
        
        XCTAssertNotEqual(hash1, hash2, "Hashes should be different for different content")
    }
}
