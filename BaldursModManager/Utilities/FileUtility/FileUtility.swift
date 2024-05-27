//
//  FileUtility.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

class FileUtility {
  /// Creates user mods and backup folders if they don't already exist.
  /// It also creates a default file in the default files directory.
  static func createUserModsAndBackupFoldersIfNeeded() {
    let fileManager = FileManager.default
    if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      let baseFolderURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName)
      _ = createDirectoryIfNeeded(at: baseFolderURL.appendingPathComponent(Constants.UserModsFolderName), withFileManager: fileManager)
      _ = createDirectoryIfNeeded(at: baseFolderURL.appendingPathComponent(Constants.UserBackupsFolderName), withFileManager: fileManager)
      let defaultFilesURL = createDirectoryIfNeeded(at: baseFolderURL.appendingPathComponent(Constants.DefaultFilesFolderName), withFileManager: fileManager)
      createDefaultSettingsFileIfNeeded(in: defaultFilesURL, withFileManager: fileManager)
    }
  }
  
  /// Creates a directory at the specified URL if it does not exist.
  ///
  /// - Parameters:
  ///   - url: The URL where the directory should be created.
  ///   - fileManager: The FileManager instance to use for file operations.
  /// - Returns: The URL where the directory was created or supposed to be.
  private static func createDirectoryIfNeeded(at url: URL, withFileManager fileManager: FileManager) -> URL {
    if !fileManager.fileExists(atPath: url.path) {
      do {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      } catch {
        Debug.log("Error creating directory at \(url.path): \(error)")
      }
    }
    return url
  }
  
  /// Creates a default settings file if it does not exist.
  ///
  /// - Parameters:
  ///   - directoryURL: The URL of the directory where the file should be created.
  ///   - fileManager: The FileManager instance to use for file operations.
  private static func createDefaultSettingsFileIfNeeded(in directoryURL: URL, withFileManager fileManager: FileManager) {
    let settingsFileURL = directoryURL.appendingPathComponent("modsettings.lsx")
    if !fileManager.fileExists(atPath: settingsFileURL.path) {
      let contents = getDefaultModSettingsLsxContents()
      do {
        try contents.write(to: settingsFileURL, atomically: true, encoding: .utf8)
      } catch {
        Debug.log("Error writing to modsettings.lsx: \(error)")
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
  
  static func appSupportDirUrl() -> URL? {
    let fileManager = FileManager.default
    guard let appSupportDirUrl = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      Debug.log("Application Support directory not found.")
      return nil
    }
    return appSupportDirUrl
  }
  
  static func moveSwiftDataStoreFiles() {
    let fileManager = FileManager.default
    guard let appSupportURL = appSupportDirUrl() else {
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
