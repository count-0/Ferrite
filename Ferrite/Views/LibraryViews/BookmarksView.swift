//
//  BookmarksView.swift
//  Ferrite
//
//  Created by Brian Dashore on 9/2/22.
//

import SwiftUI

struct BookmarksView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass

    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var debridManager: DebridManager

    @AppStorage("RealDebrid.Enabled") var realDebridEnabled = false

    let backgroundContext = PersistenceController.shared.backgroundContext

    var bookmarks: FetchedResults<Bookmark>

    @State private var viewTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            if !bookmarks.isEmpty {
                List {
                    ForEach(bookmarks, id: \.self) { bookmark in
                        SearchResultButtonView(result: bookmark.toSearchResult(), existingBookmark: bookmark)
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            if let bookmark = bookmarks[safe: index] {
                                PersistenceController.shared.delete(bookmark, context: backgroundContext)

                                NotificationCenter.default.post(name: .didDeleteBookmark, object: nil)
                            }
                        }
                    }
                    .onMove { (source, destination) in
                        var changedBookmarks = bookmarks.map { $0 }

                        changedBookmarks.move(fromOffsets: source, toOffset: destination)

                        for reverseIndex in stride(from: changedBookmarks.count - 1, through: 0, by: -1) {
                            changedBookmarks[reverseIndex].orderNum = Int16(reverseIndex)
                        }

                        PersistenceController.shared.save()
                    }
                }
                .listStyle(.insetGrouped)
                .onAppear {
                    if realDebridEnabled {
                        viewTask = Task {
                            let hashes = bookmarks.compactMap { $0.magnetHash }
                            await debridManager.populateDebridHashes(hashes)
                        }
                    }
                }
                .onDisappear {
                    viewTask?.cancel()
                }
            }
        }
    }
}
