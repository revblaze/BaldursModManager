//
//  ContentView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/5/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var modItems: [ModItem]
  
  var body: some View {
    NavigationSplitView {
      List {
        ForEach(modItems) { item in
          NavigationLink {
            Text("Item at \(item.modName) with order# \(item.order)")
          } label: {
            Text(item.modName)
          }
        }
        .onDelete(perform: deleteItems)
      }
      .navigationSplitViewColumnWidth(min: 200, ideal: 350)
      .toolbar {
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
    } detail: {
      Text("Select an item")
    }
  }
  
  private func addItem() {
    selectFile()
    /*
    withAnimation {
      let newItem = ModItem(timestamp: Date())
      modelContext.insert(newItem)
    }
     */
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
    
    if (name != nil) && (folder != nil) && (uuid != nil) && (md5 != nil) {
      withAnimation {
        let newModItem = ModItem(order: nextOrderValue(), directoryPath: directoryURL.path, directoryContents: directoryContents, name: name!, folder: folder!, uuid: uuid!, md5: md5!)
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
        print("Error parsing JSON: \(error.localizedDescription)")
      }
    }
    
    return nil
  }

  
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(modItems[index])
      }
    }
  }
  
  private func nextOrderValue() -> Int {
    (modItems.max(by: { $0.order < $1.order })?.order ?? 0) + 1
  }
}

#Preview {
  ContentView()
    .modelContainer(for: ModItem.self, inMemory: true)
}
