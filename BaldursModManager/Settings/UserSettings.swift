//
//  UserSettings.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

class UserSettings {
  static var shared = UserSettings()
  
  private let userDefaults = UserDefaults.standard
  private let keyMakeCopyOfModFolderOnImport = "makeCopyOfModFolderOnImport"
  private let keyEnableMods = "enableMods"
  private let keySaveModsAutomatically = "saveModsAutomatically"
  private let keyEnableModOnImport = "enableModOnImport"
  
  var makeCopyOfModFolderOnImport: Bool {
    get { userDefaults.bool(forKey: keyMakeCopyOfModFolderOnImport) }
    set { userDefaults.set(newValue, forKey: keyMakeCopyOfModFolderOnImport) }
  }
  
  var enableMods: Bool {
    get { userDefaults.bool(forKey: keyEnableMods) }
    set { userDefaults.set(newValue, forKey: keyEnableMods) }
  }
  
  var saveModsAutomatically: Bool {
    get { userDefaults.bool(forKey: keySaveModsAutomatically) }
    set { userDefaults.set(newValue, forKey: keySaveModsAutomatically) }
  }

  var enableModOnImport: Bool {
    get { userDefaults.bool(forKey: keyEnableModOnImport) }
    set { userDefaults.set(newValue, forKey: keyEnableModOnImport) }
  }
  
  init() {
    restoreDefaultsIfNeeded()
  }
  
  private func restoreDefaultsIfNeeded() {
    if userDefaults.object(forKey: keyMakeCopyOfModFolderOnImport) == nil {
      userDefaults.set(true, forKey: keyMakeCopyOfModFolderOnImport)
    }
    if userDefaults.object(forKey: keyEnableMods) == nil {
      userDefaults.set(true, forKey: keyEnableMods)
    }
    if userDefaults.object(forKey: keySaveModsAutomatically) == nil {
      userDefaults.set(true, forKey: keySaveModsAutomatically)
    }
    if userDefaults.object(forKey: keyEnableModOnImport) == nil {
      userDefaults.set(true, forKey: keyEnableModOnImport)
    }
  }

  func restoreDefaults() {
    userDefaults.set(true, forKey: keyMakeCopyOfModFolderOnImport)
    userDefaults.set(true, forKey: keyEnableMods)
    userDefaults.set(true, forKey: keySaveModsAutomatically)
    userDefaults.set(true, forKey: keyEnableModOnImport)
  }
}
