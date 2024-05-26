//
//  SidebarItemView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 5/26/24.
//

import SwiftUI

struct SidebarItemView: View {
  let item: ModItem

  var body: some View {
    HStack {
      Image(systemName: item.isEnabled ? "checkmark.circle.fill" : "circle")
      Text("\(item.order).")
        .foregroundStyle(.secondary)
        .monoStyle()
        .frame(minWidth: 26)
      
      Text(item.modName)
    }
  }
}
