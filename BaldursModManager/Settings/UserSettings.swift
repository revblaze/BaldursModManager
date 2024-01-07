//
//  UserSettings.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/7/24.
//

import Foundation

struct UserSettings {
  static let shared = UserSettings()
  
  private let userDefaults = UserDefaults.standard
  private let keyMakeCopyOfModFolderOnImport = "makeCopyOfModFolderOnImport"
  private let keyEnableApplicationSounds = "enableApplicationSounds"
  
  //private let keyBaldursGateDocumentsDirectoryPath = "baldursGateDocumentsDirectoryPath"
  
  var makeCopyOfModFolderOnImport: Bool {
    get { userDefaults.bool(forKey: keyMakeCopyOfModFolderOnImport) }
    set { userDefaults.set(newValue, forKey: keyMakeCopyOfModFolderOnImport) }
  }
  
  var enableApplicationSounds: Bool {
    get { userDefaults.bool(forKey: keyEnableApplicationSounds) }
    set { userDefaults.set(newValue, forKey: keyEnableApplicationSounds) }
  }
  
  /*
  var baldursGateDocumentsDirectoryPath: String {
    get {
      userDefaults.string(forKey: keyBaldursGateDocumentsDirectoryPath)
    }
    set {
      userDefaults.set(newValue, forKey: keyMakeCopyOfModFolderOnImport)
    }
  }
   */
  
  init() {
    if userDefaults.object(forKey: keyMakeCopyOfModFolderOnImport) == nil {
      // Set the default value on first launch
      userDefaults.set(true, forKey: keyMakeCopyOfModFolderOnImport)
      userDefaults.set(true, forKey: keyEnableApplicationSounds)
      //userDefaults.set("//", forKey: keyMakeCopyOfModFolderOnImport)
    }
  }
}
