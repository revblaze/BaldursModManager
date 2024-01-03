//
//  ContentView.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/2/24.
//

import SwiftUI
import AppKit

struct ContentView: View {
  @State private var modItems: [ModItem] = []
  
  var body: some View {
    VStack {
      List {
        ForEach(modItems) { item in
          VStack(alignment: .leading) {
            Text(item.directoryPath) // Display the directory path
            // Optionally display more details from the ModItem
            ForEach(item.mods) { mod in
              Text(mod.name ?? "Unknown Mod")
            }
          }
        }
        .onMove(perform: move)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toolbar {
      ToolbarItemGroup(placement: .navigation) {
        //Text("Baldur's Mod Manager").font(.headline)
      }
      ToolbarItemGroup(placement: .automatic) {
        Button(action: {
          selectFile()
        }) {
          Label("Add Mod", systemImage: "plus.app.fill")
        }
        Button(action: {
          // Action for Save Mods button
        }) {
          Label("Save Mods", systemImage: "checkmark.square.fill")
        }
      }
    }
  }
  
  private func selectFile() {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.begin { response in
      if response == .OK, let selectedDirectory = openPanel.url {
        // Process the selected directory URL here
        Debug.log("Selected directory: \(selectedDirectory.path)")
        listDirectoryContents(at: selectedDirectory)
      }
    }
  }
  
  private func listDirectoryContents(at url: URL) {
    do {
      let fileManager = FileManager.default
      let contents = try fileManager.contentsOfDirectory(atPath: url.path)
      Debug.log("Directory contents: \(contents)")

      if let infoJsonUrl = contents.first(where: { $0.caseInsensitiveCompare("info.json") == .orderedSame }) {
        let fullPath = url.appendingPathComponent(infoJsonUrl).path
        readAndLogJsonContents(atPath: fullPath, directoryContents: contents)
      }
    } catch {
      Debug.log("Error listing directory contents: \(error)")
    }
  }
  
  private func readAndLogJsonContents(atPath path: String, directoryContents: [String]) {
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        Debug.log("Contents of info.json: \(json)")

        if let modsArray = json["Mods"] as? [[String: Any]], let md5 = json["MD5"] as? String {
          let mods = modsArray.compactMap { modDict -> Mod? in
            var mod = try? JSONDecoder().decode(Mod.self, from: JSONSerialization.data(withJSONObject: modDict))
            mod?.md5 = md5
            return mod
          }
          let newModItem = ModItem(directoryPath: path, directoryContents: directoryContents, mods: mods)
          DispatchQueue.main.async {
            self.modItems.append(newModItem)
          }
        }
      }
    } catch {
      Debug.log("Error reading JSON file: \(error)")
    }
  }

  
  private func addModItem(directory: URL, directoryContents: [String], mods: [Mod]) {
    let newItem = ModItem(directoryPath: directory.path, directoryContents: directoryContents, mods: mods)
    modItems.append(newItem)
  }
  
  private func move(from source: IndexSet, to destination: Int) {
    modItems.move(fromOffsets: source, toOffset: destination)
  }
}



#Preview {
  ContentView()
}
