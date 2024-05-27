//
//  BrowseBaseGameDirectoryRow.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct BrowseBaseGameDirectoryRow: View {
  @State private var userSettings = UserSettings.shared
  var body: some View {
    VStack(alignment: .leading) {
      BrowseRequiredFileRow(labelText: "Base Game Directory",
                            placeholderText: "/Users/me/Documents/Larian Studios/Baldur's Gate 3",
                            textValue: $userSettings.baldursGateDirectory,
                            requiresEntry: true
      ){
        await FilePickerService.browseForDirectory()
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 12)
      Text("Make sure the base game directory is properly set. It should look something like this:")
        .font(.subheadline)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
      Text("/Users/me/Documents/Larian Studios/Baldur's Gate 3")
        .monoStyle()
        .padding(.horizontal, 24)
    }
  }
}

#Preview {
  BrowseBaseGameDirectoryRow()
    .padding()
}
