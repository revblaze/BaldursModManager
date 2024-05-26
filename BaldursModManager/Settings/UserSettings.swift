//
//  UserSettings.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

struct UserSettings {
  static var shared = UserSettings()
  
  private let userDefaults = UserDefaults.standard
  private let keyMakeCopyOfModFolderOnImport = "makeCopyOfModFolderOnImport"
  private let keyEnableMods = "enableMods"
  private let keySaveModsAutomatically = "saveModsAutomatically"
  
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
  
  init() {
    if userDefaults.object(forKey: keyMakeCopyOfModFolderOnImport) == nil {
      userDefaults.set(true, forKey: keyMakeCopyOfModFolderOnImport)
    }
    if userDefaults.object(forKey: keyEnableMods) == nil {
      userDefaults.set(true, forKey: keyEnableMods)
    }
    if userDefaults.object(forKey: keySaveModsAutomatically) == nil {
      userDefaults.set(true, forKey: keySaveModsAutomatically)
    }
  }
}
