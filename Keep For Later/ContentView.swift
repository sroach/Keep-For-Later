//
//  ContentView.swift
//  Keep For Later
//
//  Created by Steve Roach on 7/17/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        InboxView(viewModel: InboxViewModel(repository: SavedItemRepository(modelContext: modelContext)))
    }
}

#Preview {
    ContentView()
}
