//
//  FileUtility+BackupModSettingsLsx.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

extension FileUtility {
  /// Backs up the mod settings LSX file to the user backups directory.
  /// - Returns: The URL of the backup file if the backup was successful, otherwise nil.
  static func backupModSettingsLsxFile() -> URL? {
    let fileManager = FileManager.default
    
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
          let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      Debug.log("Unable to find the Documents or Application Support directory.")
      return nil
    }
    
    let oldModSettingsLsxFileURL = documentsURL.appendingPathComponent(Constants.defaultModSettingsFileFromDocumentsRelativePath)
    Debug.log("old modSettingsLsxFileURL: \(oldModSettingsLsxFileURL)")
    
    let modSettingsLsxFileURL = UserSettings.shared.modSettingsFileUrl ?? oldModSettingsLsxFileURL
    Debug.log("new modSettingsLsxFileURL: \(modSettingsLsxFileURL)")
    
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
      backupFileURL = userBackupsURL.appendingPathComponent("\(modSettingsLsxFileURL.deletingPathExtension().lastPathComponent).\(modSettingsLsxFileURL.pathExtension.appendingDateAndTime())")
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
  
  /// Removes the entire backup mod folder if it exists.
  static func removeBackupModSettingsDirectory() {
    let fileManager = FileManager.default
    
    guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
      Debug.log("Unable to find the Application Support directory.")
      return
    }
    
    let userBackupsURL = appSupportURL.appendingPathComponent(Constants.ApplicationSupportFolderName).appendingPathComponent(Constants.UserBackupsFolderName)
    
    if fileManager.fileExists(atPath: userBackupsURL.path) {
      do {
        try fileManager.removeItem(at: userBackupsURL)
        Debug.log("Backup folder removed successfully.")
      } catch {
        Debug.log("Failed to remove backup folder: \(error.localizedDescription)")
      }
    }
  }
}
