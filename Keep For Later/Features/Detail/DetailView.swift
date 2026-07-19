import SwiftUI
import SafariServices
import SwiftData

struct DetailView: View {
    @Bindable var item: SavedItem
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var showingSafari = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    EditView(item: item)
                } else {
                    DisplayView(item: item, openURL: { showingSafari = true })
                }
            }
            .padding()
        }
        .navigationTitle(isEditing ? "Edit Item" : (item.title ?? "Detail"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        item.updatedAt = Date()
                        item.contentHash = SavedItem.generateHash(url: item.url, snippet: item.snippet, note: item.note)
                        try? modelContext.save()
                    }
                    isEditing.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $showingSafari) {
            if let urlStr = item.url, let url = URL(string: urlStr) {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }
}

struct DisplayView: View {
    let item: SavedItem
    let openURL: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = item.title, !title.isEmpty {
                Text(title)
                    .font(.title)
                    .bold()
            }
            
            if let urlStr = item.url, !urlStr.isEmpty {
                Button(action: openURL) {
                    HStack {
                        Image(systemName: "link")
                        Text(urlStr)
                            .lineLimit(1)
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
            
            if let snippet = item.snippet, !snippet.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Snippet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(snippet)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            if let note = item.note, !note.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("My Note")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(note)
                        .font(.body)
                }
            }
            
            if !item.tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Created: \(item.createdAt, style: .date) \(item.createdAt, style: .time)")
                Text("Updated: \(item.updatedAt, style: .date) \(item.updatedAt, style: .time)")
                if let source = item.sourceApp {
                    Text("Source: \(source)")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

struct EditView: View {
    @Bindable var item: SavedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Title", text: Binding($item.title, replacingNilWith: ""))
                .textFieldStyle(.roundedBorder)
            
            TextField("URL", text: Binding($item.url, replacingNilWith: ""))
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
            
            VStack(alignment: .leading) {
                Text("Snippet")
                    .font(.headline)
                TextField("Snippet", text: Binding($item.snippet, replacingNilWith: ""), axis: .vertical)
                    .lineLimit(5...10)
                    .textFieldStyle(.roundedBorder)
            }
            
            VStack(alignment: .leading) {
                Text("Note")
                    .font(.headline)
                TextField("Note", text: Binding($item.note, replacingNilWith: ""), axis: .vertical)
                    .lineLimit(5...10)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

// Helper for nil bindings
extension Binding where Value == String {
    init(_ source: Binding<String?>, replacingNilWith defaultValue: String) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        _ = layout(proposal: proposal, subviews: subviews, bounds: bounds)
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews, bounds: CGRect? = nil) -> (size: CGSize, lastHeight: CGFloat) {
        var x: CGFloat = bounds?.minX ?? 0
        var y: CGFloat = bounds?.minY ?? 0
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        let limit = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > limit && x > (bounds?.minX ?? 0) {
                x = bounds?.minX ?? 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            
            if bounds != nil {
                subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            }
            
            x += size.width + spacing
            maxWidth = max(maxWidth, x)
            maxHeight = max(maxHeight, size.height)
        }
        
        return (CGSize(width: maxWidth, height: y + maxHeight), y + maxHeight)
    }
}
