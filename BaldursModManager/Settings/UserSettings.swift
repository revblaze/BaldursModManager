//
//  UserSettings.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

@Observable
class UserSettings {
  static var shared = UserSettings()
  
  private let userDefaults = UserDefaults.standard
  private let keyMakeCopyOfModFolderOnImport = "makeCopyOfModFolderOnImport"
  private let keyEnableMods = "enableMods"
  private let keySaveModsAutomatically = "saveModsAutomatically"
  private let keyEnableModOnImport = "enableModOnImport"
  private let keyBaldursGateDirectory = "baldursGateDirectory"
  
  var enableMods: Bool {
    didSet { userDefaults.set(enableMods, forKey: keyEnableMods) }
  }
  
  var saveModsAutomatically: Bool {
    didSet { userDefaults.set(saveModsAutomatically, forKey: keySaveModsAutomatically) }
  }
  
  var enableModOnImport: Bool {
    didSet { userDefaults.set(enableModOnImport, forKey: keyEnableModOnImport) }
  }
  
  var makeCopyOfModFolderOnImport: Bool {
    didSet { userDefaults.set(makeCopyOfModFolderOnImport, forKey: keyMakeCopyOfModFolderOnImport) }
  }
  
  var baldursGateDirectory: String {
    didSet { userDefaults.set(baldursGateDirectory, forKey: keyBaldursGateDirectory) }
  }
  
  init() {
    self.makeCopyOfModFolderOnImport = userDefaults.object(forKey: keyMakeCopyOfModFolderOnImport) as? Bool ?? true
    self.enableMods = userDefaults.object(forKey: keyEnableMods) as? Bool ?? true
    self.saveModsAutomatically = userDefaults.object(forKey: keySaveModsAutomatically) as? Bool ?? true
    self.enableModOnImport = userDefaults.object(forKey: keyEnableModOnImport) as? Bool ?? true
    self.baldursGateDirectory = userDefaults.object(forKey: keyBaldursGateDirectory) as? String ?? ""
  }
  
  func restoreDefaults() {
    self.makeCopyOfModFolderOnImport = true
    self.enableMods = true
    self.saveModsAutomatically = true
    self.enableModOnImport = true
    self.baldursGateDirectory = UserSettings.baseGameDirectoryPath()
  }
  
  static func setDefaultGameDirectoryPath() {
    Debug.log("Game Directory: \(baseGameDirectoryPath())")
    if UserSettings.shared.baldursGateDirectory.isEmpty {
      UserSettings.shared.baldursGateDirectory = baseGameDirectoryPath()
    }
  }
  
  static func baseGameDirectoryPath() -> String {
    guard let baseGameDirPath = baseGameDirUrl()?.path(percentEncoded: false) else {
      return ""
    }
    return baseGameDirPath
  }
  
  static private func baseGameDirUrl() -> URL? {
    let fileManager = FileManager.default
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
      Debug.log("Unable to find the Documents directory.")
      return nil
    }
    
    return documentsURL.appendingPathComponent(Constants.baseGameFolderFromDocumentsRelativePath)
  }
}
