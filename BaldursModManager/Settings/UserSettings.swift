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
  
  init() {
    self.makeCopyOfModFolderOnImport = userDefaults.object(forKey: keyMakeCopyOfModFolderOnImport) as? Bool ?? true
    self.enableMods = userDefaults.object(forKey: keyEnableMods) as? Bool ?? true
    self.saveModsAutomatically = userDefaults.object(forKey: keySaveModsAutomatically) as? Bool ?? true
    self.enableModOnImport = userDefaults.object(forKey: keyEnableModOnImport) as? Bool ?? true
  }
  
  func restoreDefaults() {
    self.makeCopyOfModFolderOnImport = true
    self.enableMods = true
    self.saveModsAutomatically = true
    self.enableModOnImport = true
  }
}
