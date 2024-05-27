//
//  ModItemManager.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

class ModItemManager {
  static let shared = ModItemManager()
  
  func toggleModItem(_ modItem: ModItem) {
    Debug.log("Toggling ModItem: \(modItem.modName), isEnabled: \(modItem.isEnabled)")
    
    let fileManager = FileManager.default
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      Debug.log("Unable to find the Documents directory.")
      return
    }
    
    let oldModFolderPath = documentsURL.appendingPathComponent(Constants.defaultModFolderFromDocumentsRelativePath)
    Debug.log("oldModFolderPath: \(oldModFolderPath)")
    
    let modFolderPath = UserSettings.shared.modsFolderUrl ?? oldModFolderPath
    Debug.log("newModFolderPath: \(modFolderPath)")
    
    let modItemOriginalFolderPath = URL(fileURLWithPath: modItem.directoryPath)
    let modItemPakFilePath = modItemOriginalFolderPath.appendingPathComponent(modItem.pakFileString)
    
    // Ensure the Mods folder exists
    if !fileManager.fileExists(atPath: modFolderPath.path) {
      do {
        try fileManager.createDirectory(at: modFolderPath, withIntermediateDirectories: true)
      } catch {
        Debug.log("Failed to create Mods folder: \(error.localizedDescription)")
        return
      }
    }
    
    // Determine the correct source and destination paths
    let (sourcePath, destinationPath) = modItem.isEnabled ?
    (modItemPakFilePath, modFolderPath.appendingPathComponent(modItem.pakFileString)) :
    (modFolderPath.appendingPathComponent(modItem.pakFileString), modItemPakFilePath)
    
    // Move the file
    let success = moveFile(from: sourcePath, to: destinationPath)
    
    // Update isInstalledInModFolder based on operation success
    modItem.isInstalledInModFolder = modItem.isEnabled && success
  }
  
  private func moveFile(from sourceURL: URL, to destinationURL: URL) -> Bool {
    Debug.log("Attempting to move file from \(sourceURL.path) to \(destinationURL.path)")
    
    let fileManager = FileManager.default
    do {
      if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
      }
      try fileManager.moveItem(at: sourceURL, to: destinationURL)
      Debug.log("File moved successfully from \(sourceURL.path) to \(destinationURL.path)")
      return true
    } catch {
      Debug.log("Failed to move file: \(error.localizedDescription)")
      return false
    }
  }
  
  // Before a mod item is removed, move the pak file back to its original directory
  func movePakFileToOriginalLocation(_ modItem: ModItem) {
    let fileManager = FileManager.default
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      Debug.log("Unable to find the Documents directory.")
      return
    }
    
    let oldModFolderPath = documentsURL.appendingPathComponent(Constants.defaultModFolderFromDocumentsRelativePath)
    Debug.log("oldModFolderPath: \(oldModFolderPath)")
    
    let modFolderPath = UserSettings.shared.modsFolderUrl ?? oldModFolderPath
    Debug.log("newModFolderPath: \(modFolderPath)")
    
    let modItemPakFilePath = URL(fileURLWithPath: modItem.directoryPath).appendingPathComponent(modItem.pakFileString)
    let sourcePath = modFolderPath.appendingPathComponent(modItem.pakFileString)
    
    // Move the .pak file back to the original directory
    let success = ModItemManager.shared.moveFile(from: sourcePath, to: modItemPakFilePath)
    if success {
        Debug.log("File successfully moved back to original location.")
    } else {
        Debug.log("Failed to move file back to original location.")
    }
  }
}
