import Foundation
import SwiftData
import os

enum SharedContainer {
    // Note: You must set up this App Group in Xcode Capabilities and on Apple Developer Portal.
    static let appGroupIdentifier = "group.gy.roach.keepforlater"
    
    @MainActor
    static var modelContainer: ModelContainer = {
        let schema = Schema([
            SavedItem.self,
        ])
        
        // For development/testing without App Group entitlement, 
        // you might need to fall back to default container or use a specific file URL.
        let modelConfiguration: ModelConfiguration
        
        // Check if the App Group container is actually accessible to avoid SwiftData fatalError
        let isAppGroupAvailable = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) != nil
        
        if isAppGroupAvailable {
            do {
                modelConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    groupContainer: .identifier(appGroupIdentifier)
                )
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                Logger.persistence.error("Failed to initialize ModelContainer with App Group: \(error.localizedDescription)")
            }
        } else {
            Logger.persistence.warning("App Group '\(appGroupIdentifier)' not found in entitlements or inaccessible. Falling back to local storage.")
        }

        // Fallback to standard container for local development/testing 
        // without App Group configuration.
        let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [fallbackConfiguration])
        } catch {
            fatalError("Could not create fallback ModelContainer: \(error)")
        }
    }()
}
