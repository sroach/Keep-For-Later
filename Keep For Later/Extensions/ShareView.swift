import SwiftUI
import SwiftData

struct ShareView: View {
    @State private var title: String = ""
    @State private var note: String = ""
    let url: String?
    let snippet: String?
    
    var onSave: (String, String) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Save for Later") {
                    if let url = url {
                        VStack(alignment: .leading) {
                            Text("URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(url)
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                    }
                    
                    if let snippet = snippet {
                        VStack(alignment: .leading) {
                            Text("Content")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(snippet)
                                .lineLimit(3)
                                .font(.subheadline)
                        }
                    }
                    
                    TextField("Title (Optional)", text: $title)
                    
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(5...10)
                }
            }
            .navigationTitle("Keep For Later")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, note)
                    }
                }
            }
        }
    }
}
