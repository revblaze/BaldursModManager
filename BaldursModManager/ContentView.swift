//
//  ContentView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/5/24.
//

import SwiftUI
import SwiftData

let UIDELAY: CGFloat = 0.01

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \ModItem.order, order: .forward) private var modItems: [ModItem]
  @State private var selectedModItemOrderNumber: Int?
  @State private var showAlertForModDeletion = false
  // Properties to store deletion details
  @State private var offsetsToDelete: IndexSet?
  @State private var modItemToDelete: ModItem?
  
  var body: some View {
    NavigationSplitView {
      List(selection: $selectedModItemOrderNumber) {
        ForEach(modItems) { item in
          NavigationLink {
            ModItemDetailView(item: item, deleteAction: deleteItem)
          } label: {
            HStack {
              Image(systemName: item.isEnabled ? "checkmark.circle.fill" : "circle")
              Text(item.modName)
            }
          }
          .tag(item.order)
        }
        .onDelete(perform: deleteItems)
        .onMove(perform: moveItems)
      }
      .navigationSplitViewColumnWidth(min: 200, ideal: 350)
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
        ToolbarItemGroup(placement: .navigation) {
          if Debug.isActive {
            Button(action: {
              openUserModsFolder()
            }) {
              Label("Open UserMods", systemImage: "folder")
            }
          }
        }
      }
    } detail: {
      WelcomeDetailView()
    }
    .alert(isPresented: $showAlertForModDeletion) {
      Alert(
        title: Text("Remove Mod"),
        message: Text("Are you sure you want to remove this mod? It will be moved to the trash."),
        primaryButton: .destructive(Text("Move to Trash")) {
          deleteModItems(at: offsetsToDelete, itemToDelete: modItemToDelete)
        },
        secondaryButton: .cancel()
      )
    }
  }
  
  private func openUserModsFolder() {
    if let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let userModsURL = appSupportURL//.appendingPathComponent("UserMods")
      NSWorkspace.shared.open(userModsURL)
    }
  }
  
  private func addItem() {
    selectFile()
  }
  
  private func moveItems(from source: IndexSet, to destination: Int) {
    var reorderedItems = modItems
    reorderedItems.move(fromOffsets: source, toOffset: destination)
    
    // Update the 'order' of each 'ModItem' to its new index
    for (index, item) in reorderedItems.enumerated() {
      // Assuming 'ModItem' is a managed object and 'order' is an attribute
      item.order = index
    }
    
    // Save the context
    do {
      try modelContext.save()
    } catch {
      // Handle the error, e.g., show an alert to the user
      Debug.log("Error saving context: \(error)")
    }
  }
  
  
  private func selectFile() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.begin { response in
      if response == .OK, let selectedDirectory = openPanel.url {
        Debug.log("Selected directory: \(selectedDirectory.path)")
        parseImportedModFolder(at: selectedDirectory)
      }
    }
  }
  
  private func parseImportedModFolder(at url: URL) {
    if let contents = getDirectoryContents(at: url) {
      // Find info.json file
      if let infoJsonUrl = contents.first(where: { $0.caseInsensitiveCompare("info.json") == .orderedSame }) {
        let fullPath = url.appendingPathComponent(infoJsonUrl).path
        
        if let infoDict = parseJsonToDict(atPath: fullPath) {
          Debug.log("JSON contents: \n\(infoDict)")
          
          createNewModItemFrom(infoDict: infoDict, infoJsonPath: fullPath, directoryContents: contents)
          
        } else {
          Debug.log("Error parsing JSON content. Bring up manual entry screen.")
        }
        
      } else {
        Debug.log("Error: Unable to locate info.json file of imported mod")
      }
    }
  }
  
  private func createNewModItemFrom(infoDict: [String:String], infoJsonPath: String, directoryContents: [String]) {
    let directoryURL = URL(fileURLWithPath: infoJsonPath).deletingLastPathComponent()
    
    // Required
    var name: String?
    var folder: String?
    var uuid: String?
    var md5: String?
    
    for (key, value) in infoDict {
      switch key.lowercased() {
      case "name":
        name = value
      case "folder":
        folder = value
      case "uuid":
        uuid = value
      case "md5":
        md5 = value
      default:
        break
      }
    }
    
    //if (name != nil) && (folder != nil) && (uuid != nil) && (md5 != nil) {
    if let name = name, let folder = folder, let uuid = uuid, let md5 = md5 {
      let newOrderNumber = nextOrderValue()
      withAnimation {
        //let newModItem = ModItem(order: newOrderNumber, directoryPath: directoryURL.path, directoryContents: directoryContents, name: name!, folder: folder!, uuid: uuid!, md5: md5!)
        let newModItem = ModItem(order: newOrderNumber, directoryPath: directoryURL.path, directoryContents: directoryContents, name: name, folder: folder, uuid: uuid, md5: md5)
        // Check for optional keys
        for (key, value) in infoDict {
          switch key.lowercased() {
          case "author":
            newModItem.modAuthor = value
          case "description":
            newModItem.modDescription = value
          case "created":
            newModItem.modCreatedDate = value
          case "group":
            newModItem.modGroup = value
          case "version":
            newModItem.modVersion = value
          default:
            break
          }
        }
        modelContext.insert(newModItem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + UIDELAY) {
          selectedModItemOrderNumber = newOrderNumber
        }
        
      }
    }
    
  }
  
  private func getDirectoryContents(at url: URL) -> [String]? {
    do {
      let fileManager = FileManager.default
      let contents = try fileManager.contentsOfDirectory(atPath: url.path)
      Debug.log("Directory contents: \(contents)")
      return contents
    } catch {
      Debug.log("Error listing directory contents: \(error)")
    }
    return nil
  }
  
  
  func parseJsonToDict(atPath filePath: String) -> [String: String]? {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) {
      do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let dict = jsonObject as? [String: Any],
           let mods = dict["Mods"] as? [[String: Any]],
           let firstMod = mods.first {
          
          var result: [String: String] = [:]
          
          // Extract key-value pairs from the "Mods" dictionary
          for (key, value) in firstMod {
            if let stringValue = value as? String {
              result[key] = stringValue
            }
          }
          
          // Extract MD5 from the top-level dictionary
          if let md5 = dict["MD5"] as? String {
            result["MD5"] = md5
          }
          
          return result
        }
      } catch {
        Debug.log("Error parsing JSON: \(error.localizedDescription)")
      }
    }
    
    return nil
  }
  
  // Triggered by UI delete button
  private func deleteItem(item: ModItem) {
    modItemToDelete = item
    offsetsToDelete = nil
    showAlertForModDeletion = true
  }
  
  // Triggered by menu bar item Edit > Delete
  private func deleteItems(offsets: IndexSet) {
    offsetsToDelete = offsets
    modItemToDelete = nil
    showAlertForModDeletion = true
  }
  
  private func deleteModItems(at offsets: IndexSet? = nil, itemToDelete: ModItem? = nil) {
    var indexToSelect: Int?
    
    withAnimation {
      if let offsets = offsets {
        let sortedOffsets = offsets.sorted()
        var adjustment = 0
        
        for index in sortedOffsets {
          let adjustedIndex = index - adjustment
          if adjustedIndex < modItems.count {
            indexToSelect = adjustedIndex
            modelContext.delete(modItems[adjustedIndex])
            adjustment += 1
          }
        }
      } else if let item = itemToDelete, let index = modItems.firstIndex(of: item) {
        indexToSelect = index
        modelContext.delete(modItems[index])
      }
      try? modelContext.save()    // Save the context after deletion
      updateOrderOfModItems()     // Update the order of remaining items
      
      offsetsToDelete = nil
      modItemToDelete = nil
      
      if let index = indexToSelect {
        DispatchQueue.main.asyncAfter(deadline: .now() + UIDELAY) {
          selectedModItemOrderNumber = index - 1
        }
      }
    }
  }
  
  private func updateOrderOfModItems() {
    var updatedOrder = 0
    for item in modItems.sorted(by: { $0.order < $1.order }) {
      item.order = updatedOrder
      updatedOrder += 1
    }
    
    // Save the context after reordering
    do {
      try modelContext.save()
    } catch {
      Debug.log("Error saving context after reordering: \(error)")
    }
  }
  
  private func nextOrderValue() -> Int {
    if modItems.isEmpty {
      // If there are no items, start with 0
      return 0
    } else {
      // Otherwise, find the maximum order and add 1
      return (modItems.max(by: { $0.order < $1.order })?.order ?? 0) + 1
    }
  }
  
}

#Preview {
  ContentView()
    .modelContainer(for: ModItem.self, inMemory: true)
}

struct ModItemDetailView: View {
  @Environment(\.modelContext) private var modelContext
  let item: ModItem
  let deleteAction: (ModItem) -> Void
  
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
      
      HStack {
        VStack(alignment: .leading) {
          Text(item.modName).font(.title)
            .padding(.bottom, 2)
          
          HStack {
            if let author = item.modAuthor {
              Text("by \(author)").font(.footnote)
            }
            if let version = item.modVersion {
              Spacer()
              Text("v\(version)").font(.system(.body, design: .monospaced))
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
            Text("Load Order Number: \(item.order)").font(.system(.body, design: .monospaced))
            if item.order == 0 {
              Text("(top)").font(.system(.body, design: .monospaced))
            }
          }
          .padding(.bottom, 10)
          
          if let folder = item.modFolder {
            Text("Folder: \(folder)").font(.system(.body, design: .monospaced))
              .padding(.bottom, 10)
          }
          
          Text("UUID: \(item.modUuid)").font(.system(.body, design: .monospaced))
          
          if let md5 = item.modMd5 {
            Text("MD5:  \(md5)").font(.system(.body, design: .monospaced))
          }
          
          Spacer()
          
          if Debug.isActive {
            Text(item.isInstalledInModFolder ? "Installed" : "Not Installed")
              .font(.system(.body, design: .monospaced))
          }
        }
        .padding()
        Spacer()
      }
      
      Spacer()
      
      HStack {
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
    withAnimation {
      item.isEnabled.toggle()
      try? modelContext.save()
    }
  }
}


struct WelcomeDetailView: View {
  var body: some View {
    Text("Welcome to BaldursModManager!")
  }
}
