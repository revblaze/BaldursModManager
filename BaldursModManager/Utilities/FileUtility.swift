//
//  FileUtility.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

struct FileUtility {
  static func createUserModsFolderIfNeeded() {
    let fileManager = FileManager.default
    if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let userModsURL = appSupportURL.appendingPathComponent("UserMods")
      
      if !fileManager.fileExists(atPath: userModsURL.path) {
        do {
          try fileManager.createDirectory(at: userModsURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
          Debug.log("Error creating UserMods directory: \(error)")
        }
      }
    }
  }
  
  static func moveModItemToTrash(_ modItem: ModItem) {
    let fileManager = FileManager.default
    do {
      let directoryURL = modItem.directoryUrl
      try fileManager.trashItem(at: directoryURL, resultingItemURL: nil)
      SoundUtility.play(systemSound: .trash)
    } catch {
      Debug.log("Error moving mod item to trash: \(error)")
    }
  }
  
  static func readFileContents(atPath path: String) -> String? {
    let fileManager = FileManager.default
    let filePath = path.replacingOccurrences(of: "\\", with: "")
    
    if fileManager.fileExists(atPath: filePath) {
      do {
        let contents = try String(contentsOfFile: filePath, encoding: .utf8)
        return contents
      } catch {
        Debug.log("Error reading file at \(filePath): \(error)")
      }
    } else {
      Debug.log("File does not exist at path: \(filePath)")
    }
    return nil
  }
}


