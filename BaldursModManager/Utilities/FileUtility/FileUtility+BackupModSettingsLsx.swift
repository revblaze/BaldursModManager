//
//  FileUtility+BackupModSettingsLsx.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

extension FileUtility {
  
  static func backupModSettingsLsxFile() -> URL? {
    let fileManager = FileManager.default
    
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
          let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      Debug.log("Unable to find the Documents or Application Support directory.")
      return nil
    }
    
    let modSettingsLsxFileURL = documentsURL.appendingPathComponent(Constants.defaultModSettingsFileFromDocumentsRelativePath)
    let userBackupsURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName).appendingPathComponent(Constants.UserBackupsFolderName)
    
    // Ensure the backup folder exists
    if !fileManager.fileExists(atPath: userBackupsURL.path) {
      do {
        try fileManager.createDirectory(at: userBackupsURL, withIntermediateDirectories: true)
      } catch {
        Debug.log("Failed to create backup folder: \(error.localizedDescription)")
        return nil
      }
    }
    
    // Determine the backup file URL
    var backupFileURL = userBackupsURL.appendingPathComponent(modSettingsLsxFileURL.lastPathComponent)
    if fileManager.fileExists(atPath: backupFileURL.path) {
      let timestamp = formattedCurrentTimestamp()
      backupFileURL = userBackupsURL.appendingPathComponent("\(modSettingsLsxFileURL.deletingPathExtension().lastPathComponent).\(modSettingsLsxFileURL.pathExtension) \(timestamp)")
    }
    
    // Perform the backup
    do {
      try fileManager.copyItem(at: modSettingsLsxFileURL, to: backupFileURL)
      Debug.log("Backup created successfully at \(backupFileURL.path)")
      return backupFileURL
    } catch {
      Debug.log("Failed to backup file: \(error.localizedDescription)")
      return nil
    }
  }
  
  private static func formattedCurrentTimestamp() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let datePart = dateFormatter.string(from: Date())
    
    dateFormatter.dateFormat = "h.mm.ss a"
    let timePart = dateFormatter.string(from: Date())
    
    return "\(datePart) at \(timePart)"
  }
}
