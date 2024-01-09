//
//  ModItemDetailView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import SwiftUI

struct ModItemDetailView: View {
  @Environment(\.modelContext) private var modelContext
  let item: ModItem
  let deleteAction: (ModItem) -> Void
  
  private let modItemManager = ModItemManager.shared
  @ObservedObject var debug = Debug.shared
  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button(action: { toggleEnabled() }) {
          Label(item.isEnabled ? "Enabled" : "Disabled", systemImage: item.isEnabled ? "checkmark.circle.fill" : "circle")
            .frame(width: 80)
            .padding(6)
        }
        .buttonStyle(.bordered)
        .tint(item.isEnabled ? .green : .gray)
      }
      
      ScrollView {
        HStack {
          VStack(alignment: .leading) {
            Text(item.modName).font(.title)
              .padding(.bottom, 2)
            
            HStack {
              if let author = item.modAuthor {
                Text("by \(author)").font(.footnote)
              }
              if let version = item.modVersion {
                Text("(v\(version))").monoStyle()
              }
            }
            
            if let summary = item.modDescription {
              Divider()
                .padding(.vertical, 10)
              
              Text(summary)
            }
            
            Divider()
              .padding(.vertical, 10)
            
            HStack {
              Text("Load Order Number: \(item.order)").monoStyle()
              if item.order == 0 {
                Text("(top)").monoStyle()
              }
            }
            .padding(.bottom, 10)
            
            if let folder = item.modFolder {
              Text("Folder: \(folder)").monoStyle()
                .padding(.bottom, 10)
            }
            
            Text("UUID: \(item.modUuid)").monoStyle()
            
            if let md5 = item.modMd5 {
              Text("MD5:  \(md5)").monoStyle()
            }
            
            if debug.isActive {
              Divider()
                .padding(.vertical, 10)
              
              Text("Debug Info").font(.headline)
                .padding(.bottom, 10)
              
              Text("PAK File String: \(item.pakFileString)").monoStyle()
                .padding(.bottom, 5)
              
              Text("Directory Path: \(item.directoryPath)").monoStyle()
                .padding(.bottom, 5)
              
              Text("Directory URL: \(item.directoryUrl.absoluteString)").monoStyle()
                .padding(.bottom, 5)
              
              Text("Directory Contents:\n  \(item.directoryContents[0])\n  \(item.directoryContents[1])").monoStyle()
                .padding(.bottom, 5)
            }
            
            Spacer()
            
          }
          .padding()
          Spacer()
        }
        Spacer()
      }
      
      HStack {
        if debug.isActive {
          Text(item.isInstalledInModFolder ? "Installed" : "Not Installed")
            .monoStyle()
        }
        Spacer()
        Button(action: { deleteAction(item) }) {
          Label("Remove", systemImage: "trash.circle.fill")
            .padding(6)
        }
        .buttonStyle(.bordered)
        .tint(.red)
        
      }
    }
    .padding()
    
  }
  
  private func toggleEnabled() {
    Debug.log("toggleEnabled()")
    withAnimation {
      item.isEnabled.toggle()
      try? modelContext.save()
    }
    modItemManager.toggleModItem(item)
  }
}

#Preview {
  ModItemDetailView(item: ModItem.mock, deleteAction: { _ in })
}

extension ModItem {
  static var mock: ModItem {
    ModItem(order: 1,
            directoryUrl: URL(fileURLWithPath: "/path/to/modItem"),
            directoryPath: "/path/to/modItem",
            directoryContents: ["file1.pak", "file2.pak"],
            pakFileString: "mockPakFile.pak",
            name: "Mock Mod Item",
            folder: "MockFolder",
            uuid: "1234-5678",
            md5: "9abcdef0")
  }
}
