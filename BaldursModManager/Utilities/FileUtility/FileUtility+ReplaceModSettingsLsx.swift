//
//  FileUtility+ReplaceModSettingsLsx.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/8/24.
//

import Foundation

extension FileUtility {
  /// Replaces the modsettings.lsx file in the User Documents with new contents and sets appropriate permissions.
  ///
  /// - Parameter withFileContents: The new contents to be written to the modsettings.lsx file.
  static func replaceModSettingsLsxInUserDocuments(withFileContents: String) {
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let oldModSettingsFileURL = documentsURL.appendingPathComponent(Constants.defaultModSettingsFileFromDocumentsRelativePath)
    Debug.log("old modSettingsFileURL:\(oldModSettingsFileURL)")
    let modSettingsFileURL = UserSettings.shared.modSettingsFileUrl ?? oldModSettingsFileURL
    Debug.log("new modSettingsFileURL:\(modSettingsFileURL)")
    
    // Remove existing file if it exists
    if fileManager.fileExists(atPath: modSettingsFileURL.path) {
      do {
        try fileManager.removeItem(at: modSettingsFileURL)
      } catch {
        Debug.log("Error removing existing modsettings.lsx file: \(error)")
        return
      }
    }
    
    // Write new contents to the file
    do {
      try withFileContents.write(to: modSettingsFileURL, atomically: true, encoding: .utf8)
      
      // Set file permissions: User read-write, others read-only
      let fileAttributes: [FileAttributeKey: Any] = [.posixPermissions: 0o644]
      try fileManager.setAttributes(fileAttributes, ofItemAtPath: modSettingsFileURL.path)
    } catch {
      Debug.log("Error writing new modsettings.lsx file: \(error)")
    }
  }
}
