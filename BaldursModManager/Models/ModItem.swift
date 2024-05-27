//
//  ModItem.swift
//  BaldursModManager
//
//  Created by Justin Bush on 1/5/24.
//

import Foundation
import SwiftData

@Model
class ModItem {
  var order: Int
  var directoryUrl: URL
  var directoryPath: String
  var directoryContents: [String]
  var pakFileString: String
  var isEnabled: Bool = false
  var isInstalledInModFolder: Bool = false
  // Mod Metadata Required: [Name, Folder, UUID, MD5]
  var modAuthor: String?
  var modCreatedDate: String?
  var modDescription: String?
  var modFolder: String?
  var modGroup: String?
  var modName: String
  var modUuid: String
  var modVersion: String?
  var modMd5: String?
  
  init(order: Int, directoryUrl: URL, directoryPath: String, directoryContents: [String], pakFileString: String, name: String, folder: String, uuid: String, md5: String) {
    self.order = order
    self.directoryUrl = directoryUrl
    self.directoryPath = directoryPath
    self.directoryContents = directoryContents
    self.pakFileString = pakFileString
    self.modName = name
    self.modFolder = folder
    self.modUuid = uuid
    self.modMd5 = md5
  }
}

class ModItemUtility {
  static func logModItems(_ modItems: [ModItem]) {
    Debug.shared.logModItems = false
    for modItem in modItems {
      Debug.log("[ModItem] \(modItem.modName)")
      Debug.log("Order: \(modItem.order)")
      Debug.log("Directory URL: \(modItem.directoryUrl)")
      Debug.log("Directory Path: \(modItem.directoryPath)")
      Debug.log("Directory Contents: \(modItem.directoryContents.joined(separator: ", "))")
      Debug.log("PAK File String: \(modItem.pakFileString)")
      Debug.log("Is Enabled: \(modItem.isEnabled)")
      Debug.log("Is Installed In Mod Folder: \(modItem.isInstalledInModFolder)")
      Debug.log("Mod Author: \(modItem.modAuthor ?? "N/A")")
      Debug.log("Mod Created Date: \(modItem.modCreatedDate ?? "N/A")")
      Debug.log("Mod Description: \(modItem.modDescription ?? "N/A")")
      Debug.log("Mod Folder: \(modItem.modFolder ?? "N/A")")
      Debug.log("Mod Group: \(modItem.modGroup ?? "N/A")")
      Debug.log("Mod Name: \(modItem.modName)")
      Debug.log("Mod UUID: \(modItem.modUuid)")
      Debug.log("Mod Version: \(modItem.modVersion ?? "N/A")")
      Debug.log("Mod MD5: \(modItem.modMd5 ?? "N/A")")
      Debug.log("----------------------------------------------------")
    }
  }
}
