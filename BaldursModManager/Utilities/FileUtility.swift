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
}
