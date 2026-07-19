import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var appLockEnabled = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingExport = false
    @State private var exportURL: URL?
    @State private var showingImport = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Data Management") {
                    Button(action: {
                        exportData()
                    }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: {
                        showingImport = true
                    }) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                }
                
                Section("Security") {
                    Toggle("App Lock (FaceID/Passcode)", isOn: $appLockEnabled)
                        .disabled(true) // Placeholder for MVP
                    Text("App lock is a placeholder in this MVP.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExport) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .fileImporter(
                isPresented: $showingImport,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    importData(from: url)
                case .failure(let error):
                    alertMessage = "Import failed: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
            .alert("Import Result", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func exportData() {
        let manager = ImportExportManager(repository: SavedItemRepository(modelContext: modelContext))
        do {
            exportURL = try manager.exportAll()
            showingExport = true
        } catch {
            alertMessage = "Export failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func importData(from url: URL) {
        let manager = ImportExportManager(repository: SavedItemRepository(modelContext: modelContext))
        do {
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                let result = try manager.importFrom(url: url)
                alertMessage = "Import finished:\nInserted: \(result.inserted)\nSkipped: \(result.skipped)\nErrors: \(result.errors)"
                showingAlert = true
            }
        } catch {
            alertMessage = "Import failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
