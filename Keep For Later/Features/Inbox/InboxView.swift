import SwiftUI
import SwiftData

struct InboxView: View {
    @StateObject var viewModel: InboxViewModel
    @State private var showingAddSheet = false
    @State private var showingSettingsSheet = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            VStack {
                if !viewModel.allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.allTags, id: \.self) { tag in
                                TagChip(
                                    tag: tag,
                                    isSelected: viewModel.selectedTags.contains(tag),
                                    action: { viewModel.toggleTag(tag) }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                List {
                    ForEach(viewModel.items) { item in
                        NavigationLink(value: item) {
                            ItemRow(item: item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.delete(item: item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                viewModel.archive(item: item)
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                            .tint(.orange)
                        }
                    }
                }
                .refreshable {
                    viewModel.refresh()
                }
                .overlay {
                    if viewModel.items.isEmpty {
                        ContentUnavailableView(
                            viewModel.searchText.isEmpty ? "No Items" : "No Results",
                            systemImage: viewModel.searchText.isEmpty ? "tray" : "magnifyingglass",
                            description: Text(viewModel.searchText.isEmpty ? "Save something for later!" : "Try a different search term.")
                        )
                    }
                }
            }
            .navigationTitle("Inbox")
            .searchable(text: $viewModel.searchText, prompt: "Search items")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettingsSheet = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: SavedItem.self) { item in
                DetailView(item: item)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddView(viewModel: AddViewModel(repository: SavedItemRepository(modelContext: modelContext)))
            }
            .sheet(isPresented: $showingSettingsSheet) {
                SettingsView()
            }
        }
        .onAppear {
            viewModel.refresh()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                viewModel.refresh()
            }
        }
    }
}

struct TagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ItemRow: View {
    let item: SavedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = item.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
            } else if let url = item.url, !url.isEmpty {
                Text(url)
                    .font(.headline)
                    .lineLimit(1)
            } else {
                Text("Untitled")
                    .font(.headline)
                    .italic()
            }
            
            if let snippet = item.snippet, !snippet.isEmpty {
                Text(snippet)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Text(item.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let urlStr = item.url, let url = URL(string: urlStr), let host = url.host() {
                    Text("• \(host)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
