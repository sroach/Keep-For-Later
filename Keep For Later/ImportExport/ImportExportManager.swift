import Foundation
import SwiftData
import Combine

struct ImportResult {
    var inserted: Int = 0
    var skipped: Int = 0
    var errors: Int = 0
}

@MainActor
final class ImportExportManager: ObservableObject {
    private let repository: SavedItemRepositoryProtocol
    
    init(repository: SavedItemRepositoryProtocol) {
        self.repository = repository
    }
    
    func exportAll() throws -> URL {
        let items = try repository.fetchAll()
        let dtos = items.map { SavedItemDTO(from: $0) }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(dtos)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString = formatter.string(from: Date())
        let filename = "keep_for_later_export_\(dateString).json"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        // Clean up old exports in temp dir if any
        let tempDir = FileManager.default.temporaryDirectory
        let contents = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
        for file in contents where file.lastPathComponent.starts(with: "keep_for_later_export_") {
            try? FileManager.default.removeItem(at: file)
        }
        
        try data.write(to: tempURL)
        
        return tempURL
    }
    
    func importFrom(url: URL) throws -> ImportResult {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dtos = try decoder.decode([SavedItemDTO].self, from: data)
        var result = ImportResult()
        
        for dto in dtos {
            do {
                let item = dto.toModel()
                if let _ = try repository.findByHash(item.contentHash) {
                    result.skipped += 1
                } else {
                    try repository.create(item)
                    result.inserted += 1
                }
            } catch {
                result.errors += 1
            }
        }
        
        return result
    }
}
