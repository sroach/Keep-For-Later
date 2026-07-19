import SwiftUI

struct AddView: View {
    @StateObject var viewModel: AddViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Content") {
                    HStack {
                        TextField("URL", text: $viewModel.url)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        if viewModel.showPasteButton {
                            Button {
                                viewModel.pasteFromClipboard()
                            } label: {
                                Image(systemName: "doc.on.clipboard")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    
                    TextField("Title (Optional)", text: $viewModel.title)
                    
                    TextField("Snippet", text: $viewModel.snippet, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Personal Notes") {
                    TextField("Note", text: $viewModel.note, axis: .vertical)
                        .lineLimit(5...10)
                    
                    TextField("Tags (comma separated)", text: $viewModel.tagsString)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.checkClipboard()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isSaveDisabled)
                }
            }
        }
    }
}
