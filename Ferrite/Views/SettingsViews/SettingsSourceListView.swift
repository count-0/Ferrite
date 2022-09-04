//
//  SettingsSourceListView.swift
//  Ferrite
//
//  Created by Brian Dashore on 7/25/22.
//

import SwiftUI

struct SettingsSourceListView: View {
    let backgroundContext = PersistenceController.shared.backgroundContext

    @EnvironmentObject var navModel: NavigationViewModel

    @FetchRequest(
        entity: SourceList.entity(),
        sortDescriptors: []
    ) var sourceLists: FetchedResults<SourceList>

    @State private var presentSourceSheet = false
    @State private var selectedSourceList: SourceList?

    var body: some View {
        List {
            if sourceLists.isEmpty {
                Text("No source lists")
            } else {
                ForEach(sourceLists, id: \.self) { sourceList in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(sourceList.name)

                        Text(sourceList.author)
                            .foregroundColor(.gray)

                        Text("ID: \(sourceList.id)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 2)
                    .contextMenu {
                        Button {
                            navModel.selectedSourceList = sourceList
                            presentSourceSheet.toggle()
                        } label: {
                            Text("Edit")
                            Image(systemName: "pencil")
                        }

                        if #available(iOS 15.0, *) {
                            Button(role: .destructive) {
                                PersistenceController.shared.delete(sourceList, context: backgroundContext)
                            } label: {
                                Text("Remove")
                                Image(systemName: "trash")
                            }
                        } else {
                            Button {
                                PersistenceController.shared.delete(sourceList, context: backgroundContext)
                            } label: {
                                Text("Remove")
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .sheet(isPresented: $presentSourceSheet) {
            if #available(iOS 16, *) {
                SourceListEditorView(sourceUrl: navModel.selectedSourceList?.urlString ?? "")
                    .presentationDetents([.medium])
            } else {
                SourceListEditorView(sourceUrl: navModel.selectedSourceList?.urlString ?? "")
            }
        }
        .navigationTitle("Source Lists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentSourceSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct SettingsSourceListView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSourceListView()
    }
}
