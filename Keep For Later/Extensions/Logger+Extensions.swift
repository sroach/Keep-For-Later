import Foundation
import os

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "roach.gy.Keep-For-Later"

    /// Logs related to data persistence and SwiftData
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    
    /// Logs related to UI and ViewModels
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Logs related to the Share Extension
    static let shareExtension = Logger(subsystem: subsystem, category: "shareExtension")
}
