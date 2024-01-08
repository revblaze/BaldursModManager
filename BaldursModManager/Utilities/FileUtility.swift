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
      let userModsURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName).appendingPathComponent("UserMods")
      
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
  
  static func readFileFromDocumentsFolder(documentsFilePath: String) -> String? {
    let fileManager = FileManager.default
    
    // Find the user's Documents directory
    if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
      let fileURL = documentsDirectory.appendingPathComponent(documentsFilePath)
      
      do {
        let contents = try String(contentsOf: fileURL, encoding: .utf8)
        return contents
      } catch {
        Debug.log("Error reading file at \(fileURL): \(error)")
      }
    } else {
      Debug.log("Documents directory not found.")
    }
    
    return nil
  }
  
}

extension FileUtility {
  
  static func moveSwiftDataStoreFiles() {
    let fileManager = FileManager.default
    guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      Debug.log("Application Support directory not found.")
      return
    }
    
    let swiftDataFiles = ["default.store", "default.store-shm", "default.store-wal"]
    let destinationSubfolderURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName, isDirectory: true)
    
    // Create the destination subfolder if it doesn't exist
    if !fileManager.fileExists(atPath: destinationSubfolderURL.path) {
      do {
        try fileManager.createDirectory(at: destinationSubfolderURL, withIntermediateDirectories: true)
      } catch {
        Debug.log("Error creating directory: \(error)")
        return
      }
    }
    
    for fileName in swiftDataFiles {
      let sourceURL = appSupportURL.appendingPathComponent(fileName)
      if fileManager.fileExists(atPath: sourceURL.path) {
        let destinationURL = destinationSubfolderURL.appendingPathComponent(fileName)
        do {
          try fileManager.moveItem(at: sourceURL, to: destinationURL)
          Debug.log("Moved \(fileName) to \(destinationURL.path)")
        } catch {
          Debug.log("Failed to move \(fileName): \(error)")
        }
      }
    }
  }
  
}
